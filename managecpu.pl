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

# change cpu rate if you want
my $cpu_rate     = 50000;
my $croot        = File::Spec->catfile("/sys", "fs", "cgroup", "cpu");

die "CFS not suppport" if ! -d $croot;

my $pid          = $$;
my $fork         = new Parallel::ForkManager(2);
my $command      = join " ", @ARGV;

die "argv not found" if $command eq "";

our $MCPU_DIR     = File::Spec->catfile($croot, "cpu_manage");
mkdir $MCPU_DIR if ! -d $MCPU_DIR;

$SIG{INT} = $SIG{TERM} = sub { emergency($fork, $pid) };

if ($fork->start == 0) {

    my $ppid            = $$;
    my $group           = File::Spec->catfile($MCPU_DIR, $pid);
    my $tasks           = File::Spec->catfile($group, "tasks");
    my $cfs_quota_us    = File::Spec->catfile($group, "cpu.cfs_quota_us");

    mkdir $group;
    system("echo $ppid > $tasks");
    system("echo $cpu_rate > $cfs_quota_us");
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
    my ($fork, $pid) = @_;
    $fork->finish;
    $fork->wait_all_children;   
    cleanup($pid);
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

