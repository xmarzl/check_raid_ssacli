#!/usr/bin/env perl

# -- imports
use strict;
use warnings;
use Getopt::Long;

# -- global variables
my $verbose = 0;
my $command_ssacli_list_controller = 'ssacli ctrl all show';
my $ssacli_response_failed = 'Failed';
my $ssacli_response_ok = 'OK';

my %error = (
  'ok'       => 0,
  'warning'  => 1,
  'critical' => 2,
  'unknown'  => 3
);

# -- subs
sub verbose($) {
  my $f_message = shift;
  print 'verbose: '.$f_message."\n" if($verbose);
}

sub help() {
  print '-v --verbose'."\n";
  print '-h --help'."\n";
  print 'perl check_raid_ssacli.pl -v'."\n";
  exit($error{'unknown'});
}

# -- Getoptions
&GetOptions(
  'v|verbose!' => \$verbose,
  'h|help!' => sub { &help() }
);

# -- init
my %controller = ();

my $output = '';

my $state_failed = 0;
my $state_ok = 0;
my $state_unknown = 0;

# -- script start
&verbose('-- Verbose mode enabled --');

# --- getting controllers
&verbose('Executing command: '.$command_ssacli_list_controller);
my $command_ssacli_list_controller_output = `$command_ssacli_list_controller`;
&verbose('Command output: "'.$command_ssacli_list_controller_output.'"');

# ---- splitting output lines
my @output_lines = split(/\n/, $command_ssacli_list_controller_output);

# ---- getting controller names and slots
for my $line (@output_lines) {

  # ----- skip empty lines
  next if $line =~ /^\s*$/;

  # ---- get controller name and slot
  my ($controller_name, $controller_slot) = $line =~ /^Smart Array (\w+) in Slot (\w+).*$/;
  &verbose('Controller: '.$controller_name.' - '.$controller_slot);

  # ---- add slot + name to hash
  $controller{$controller_slot} = $controller_name;
}

$output = $output.'Logicaldrives:'."\n";
# --- checking logicaldrives of controllers
for my $controller_slot(keys %controller) {
  my $controller_name = $controller{$controller_slot};
  &verbose('Checking logical drives of controller "'.$controller_name.'" (Slot '.$controller_slot.')');

  # ---- creating and executing command
  my $command_list_logicaldrive_status = 'ssacli ctrl slot='.$controller_slot.' ld all show status';
  &verbose('Executing command: '.$command_list_logicaldrive_status);
  my $command_list_logicaldrive_status_output = `$command_list_logicaldrive_status`;
  &verbose('Command output: "'.$command_list_logicaldrive_status_output.'"');

  # ---- splitting output lines
  @output_lines = split(/\n/, $command_list_logicaldrive_status_output);

  # ---- getting logicaldrives
  for my $line (@output_lines) {

    # ----- skip empty lines
    next if $line =~ /^\s*$/;

    # ----- get logicaldrive and state and append output
    my ($logicaldrive_info, $logicaldrive_status) = $line =~ /^\s*(logicaldrive.+) (\w+).*$/;
    &verbose($logicaldrive_info.' - '.$logicaldrive_status);
    $output = $output.'- '.$logicaldrive_info.' - '.$logicaldrive_status."\n";

    # ----- check response
    if($logicaldrive_status eq $ssacli_response_ok){
      $state_ok += 1;
    }elsif($logicaldrive_status eq $ssacli_response_failed){
      $state_failed += 1;
    }else{
      $state_unknown += 1;
    }
  }
}

$output = $output.'Physicaldrives:'."\n";
# --- checking physicaldrives of controllers
for my $controller_slot(keys %controller) {
  my $controller_name = $controller{$controller_slot};
  &verbose('Checking physical drives of controller "'.$controller_name.'" (Slot '.$controller_slot.')');

  # ---- creating and executing command
  my $command_list_physicaldrive_status = 'ssacli ctrl slot='.$controller_slot.' pd all show status';
  &verbose('Executing command: '.$command_list_physicaldrive_status);
  my $command_list_physicaldrive_status_output = `$command_list_physicaldrive_status`;
  &verbose('Command output: "'.$command_list_physicaldrive_status_output.'"');

  # ---- splitting output lines
  @output_lines = split(/\n/, $command_list_physicaldrive_status_output);

  # ---- getting physicaldrives
  for my $line (@output_lines) {

    # ----- skip empty lines
    next if $line =~ /^\s*$/;

    # ----- get physicaldrive and state
    my ($physicaldrive_info, $physicaldrive_status) = $line =~ /^\s*(physicaldrive.+) (\w+).*$/;
    &verbose($physicaldrive_info.' - '.$physicaldrive_status);
    $output = $output.'- '.$physicaldrive_info.' - '.$physicaldrive_status."\n";

    # ----- check response and append output
    if($physicaldrive_status eq $ssacli_response_ok){
      $state_ok += 1;
    }elsif($physicaldrive_status eq $ssacli_response_failed){
      $state_failed += 1;
    }else{
      $state_unknown += 1;
    }
  }
}

# --- printing title and output
print 'OK:'.$state_ok.' - Failed:'.$state_failed.' - Unknown:'.$state_unknown."\n";
print $output."\n";

# -- exit script
if($state_failed > 0) {
  exit($error{'critical'});
}elsif($state_unknown > 0) {
  exit($error{'warning'});
}elsif($state_ok > 0) {
  exit($error{'ok'});
}

exit($error{'unknown'});
