#!/usr/bin/perl

use strict;
use warnings;
use Parallel::ForkManager;
use File::Spec;

my $cpu_rate     = 50000;
my $croot        = File::Spec->catfile("/sys", "fs", "cgroup", "cpu");

our $mcpu_dir    = File::Spec->catfile($croot, "cpu_manage");
our $tasks        = File::Spec->catfile($mcpu_dir, "tasks");
our $cfs_quota_us = File::Spec->catfile($mcpu_dir, "cpu.cfs_quota_us");

my $fork         = new Parallel::ForkManager(1);
my $command      = join " ", @ARGV;

mkdir $mcpu_dir if ! -d $mcpu_dir;

while ($fork->start) {
    my $pid = $$;
    print "pid = $pid\n";
    
    $SIG{INT} = $SIG{TERM} = sub { emergency($pid) };
    
    mkdir File::Spec->catfile($mcpu_dir, $pid);
    system("echo $pid > $tasks");
    system("echo $cpu_rate > $cfs_quota_us");
    system($command);
    
    $fork->finish;
    cleanup($pid);
}

$fork->wait_all_children;   

sub cleanup {
    my $pid = shift;
    rmdir File::Spec->catfile($mcpu_dir, $pid);
    exit 0;
}

sub emergency {
    my $pid = shift;
    rmdir File::Spec->catfile($mcpu_dir, $pid);
    exit 1;
}
