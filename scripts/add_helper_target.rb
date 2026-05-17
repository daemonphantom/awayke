#!/usr/bin/env ruby
# Adds the AwaykeHelper target to Awayke.xcodeproj.
# Idempotent: re-running won't duplicate.

require 'xcodeproj'

PROJECT_PATH    = File.expand_path('../Awayke.xcodeproj', __dir__)
HELPER_NAME     = 'AwaykeHelper'                # Xcode target name
HELPER_BUNDLE   = 'daemonphantom.Awayke.Helper' # Bundle ID + product file name
DEPLOYMENT_TGT  = '14.0'

project = Xcodeproj::Project.open(PROJECT_PATH)

main_target = project.targets.find { |t| t.name == 'Awayke' }
abort "Couldn't find Awayke target" unless main_target

helper_target = project.targets.find { |t| t.name == HELPER_NAME }
if helper_target
  puts "Helper target already exists — updating settings only."
else
  helper_target = project.new_target(:command_line_tool, HELPER_NAME, :osx, DEPLOYMENT_TGT)
  puts "Created helper target."
end

# --- Group for helper files ---
helper_group = project.main_group.find_subpath('AwaykeHelper', true)
helper_group.set_source_tree('SOURCE_ROOT')
helper_group.set_path('AwaykeHelper')

def find_or_make_ref(group, filename)
  existing = group.files.find { |f| f.path == filename }
  return existing if existing
  group.new_reference(filename)
end

main_ref     = find_or_make_ref(helper_group, 'main.swift')
protocol_ref = find_or_make_ref(helper_group, 'AwaykeHelperProtocol.swift')
info_ref     = find_or_make_ref(helper_group, 'Info.plist')
launchd_ref  = find_or_make_ref(helper_group, 'daemonphantom.Awayke.Helper.plist')
entitle_ref  = find_or_make_ref(helper_group, 'AwaykeHelper.entitlements')

# --- Helper target compiles main.swift + protocol.swift ---
helper_sources = helper_target.source_build_phase
[main_ref, protocol_ref].each do |ref|
  next if helper_sources.files_references.include?(ref)
  helper_sources.add_file_reference(ref)
end

# --- Main app also compiles the shared protocol file ---
main_sources = main_target.source_build_phase
unless main_sources.files_references.include?(protocol_ref)
  main_sources.add_file_reference(protocol_ref)
end

# --- Helper build settings ---
helper_target.build_configurations.each do |config|
  bs = config.build_settings
  bs['MACOSX_DEPLOYMENT_TARGET']     = DEPLOYMENT_TGT
  # PRODUCT_NAME = bundle ID so the helper executable filename matches its
  # Label. SMAppService daemon registration appears to be sensitive to this:
  # in every working Apple sample, Contents/MacOS/<bundleID> is the binary.
  bs['PRODUCT_NAME']                 = HELPER_BUNDLE
  bs['PRODUCT_BUNDLE_IDENTIFIER']    = HELPER_BUNDLE
  bs['SWIFT_VERSION']                = '5.0'
  bs['ENABLE_HARDENED_RUNTIME']      = 'YES'
  bs['ENABLE_APP_SANDBOX']           = 'NO'
  bs['CODE_SIGN_ENTITLEMENTS']       = 'AwaykeHelper/AwaykeHelper.entitlements'
  bs['CODE_SIGN_STYLE']              = 'Automatic'
  bs['SKIP_INSTALL']                 = 'YES'
  bs['OTHER_LDFLAGS']                = '-sectcreate __TEXT __info_plist "$(SRCROOT)/AwaykeHelper/Info.plist"'
  bs['CLANG_ENABLE_MODULES']         = 'YES'
end

# --- Target dependency: main app needs helper built first ---
unless main_target.dependencies.any? { |d| d.target == helper_target }
  main_target.add_dependency(helper_target)
end

# --- Copy Helper Executable into Awayke.app/Contents/MacOS/ ---
copy_exec_phase = main_target.copy_files_build_phases.find { |p| p.name == 'Copy Helper Executable' }
unless copy_exec_phase
  copy_exec_phase = main_target.new_copy_files_build_phase('Copy Helper Executable')
  copy_exec_phase.dst_path = ''
  copy_exec_phase.dst_subfolder_spec = '6' # Executables (Contents/MacOS)
end
helper_product = helper_target.product_reference
# No CodeSignOnCopy: the helper is signed during its own target build
# with its own entitlements + hardened runtime. The main app's signing
# phase seals over the entire bundle including the already-signed
# helper. Re-signing on copy would clobber the helper's entitlements.
exec_buildfile = copy_exec_phase.files.find { |bf| bf.file_ref == helper_product }
exec_buildfile ||= copy_exec_phase.add_file_reference(helper_product)
exec_buildfile.settings = nil

# --- Copy Launchd plist into Awayke.app/Contents/Library/LaunchDaemons/ ---
copy_plist_phase = main_target.copy_files_build_phases.find { |p| p.name == 'Copy Launchd Plist' }
unless copy_plist_phase
  copy_plist_phase = main_target.new_copy_files_build_phase('Copy Launchd Plist')
  copy_plist_phase.dst_path = 'Contents/Library/LaunchDaemons'
  copy_plist_phase.dst_subfolder_spec = '1' # Wrapper (.app bundle root)
end
unless copy_plist_phase.files_references.include?(launchd_ref)
  copy_plist_phase.add_file_reference(launchd_ref)
end

project.save
puts "Saved #{PROJECT_PATH}"
puts "Targets now: #{project.targets.map(&:name).join(', ')}"
