#!/usr/bin/perl

use strict;
use warnings;
use Parallel::ForkManager;
use File::Spec;
use Getopt::Long;
use Pod::Usage;

our $VERSION = "0.0.1";

GetOptions (
    'h|help'    => \my $help,
    'v|version' => \my $version,
) or pod2usage(2);

$version and do { print "managecpu.pl: $VERSION\n"; exit 0 };
pod2usage(1) if $help;

my $cpu_rate     = 50000;
my $croot        = File::Spec->catfile("/sys", "fs", "cgroup", "cpu");

die "CFS not suppport" if ! -d $croot;

our $MCPU_DIR     = File::Spec->catfile($croot, "cpu_manage");
our $TASKS        = File::Spec->catfile($MCPU_DIR, "tasks");
our $CFS_QUOTA_US = File::Spec->catfile($MCPU_DIR, "cpu.cfs_quota_us");

my $fork         = new Parallel::ForkManager(1);
my $command      = join " ", @ARGV;

die "argv not found" if $command eq "";

mkdir $MCPU_DIR if ! -d $MCPU_DIR;

while ($fork->start) {
    my $pid = $$;
    print "pid = $pid\n";
    
    $SIG{INT} = $SIG{TERM} = sub { emergency($pid) };
    
    mkdir File::Spec->catfile($MCPU_DIR, $pid);
    system("echo $pid > $TASKS");
    system("echo $cpu_rate > $CFS_QUOTA_US");
    system($command);
    
    $fork->finish;
    cleanup($pid);
}

$fork->wait_all_children;   
exit 0;

sub cleanup {
    my $pid = shift;
    rmdir File::Spec->catfile($MCPU_DIR, $pid);
    exit 0;
}

sub emergency {
    my $pid = shift;
    rmdir File::Spec->catfile($MCPU_DIR, $pid);
    exit 1;
}

__END__

=head1 NAME

managecpu - managed cpu rate by CFS

=head1 SYNOPSIS
 
 managecpu.pl command

    ex) ./managecpu.pl sh while.sh

 Options:
    -help -h                       brief help message

=head1 AUTHOR

MATSUMOTO Ryosuke

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

