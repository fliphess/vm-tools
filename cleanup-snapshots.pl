#!/usr/bin/perl
use strict;
use warnings;
use 5.10.0;
use File::Basename;
use Getopt::Long;

my $snapshots = '/srv';

#
# Lets get started :)
#

# Get options or show usage
# {{{ - Get options and or show usage

my $go;
my $options = GetOptions(
	"h|help|?"   	=> \&usage,
	"c|cleanup"	=> \$go,
) || usage();
usage() unless $go;

# }}}


if (not -x '/usr/bin/virsh' or not -x '/sbin/btrfs' ) {
    say "This script heavily depends on virsh and btrfs-tools!";
    exit 1;
}

#
# Do the magic :)
#

main();
exit 0;

sub main { # {{{ - Run the main routine

	my @subvolumes = get_subvolumes();
	my @cleanup;

	foreach my $subvolume (@subvolumes) {
		next if ( $subvolume =~ /base-/ );
		next if not ($subvolume  =~ /^images/ );
		push(@cleanup,$subvolume);
	}

	my $total = scalar(@cleanup);
	if ($total == 0) {
		say "No orphan subvolumes found!";
		say "Happy happy joy joy! :)";
		exit 0;
	}

	say "\nI\'m going to clean up $total volumes: @cleanup";
	my $command = 'cd /srv ; /sbin/btrfs subvolume delete %s';

	foreach my $del (@cleanup) {
		my $run = sprintf($command,$del);
		my @output  = `$run 2>&1`;
		my $success = $? >> 8;
		if ( not $success == 0 ) {
			say "Failed to delete subvolume $del";
			say "Output was: @output";
			next;
		}
		else {
			say "Deleted $del, Output was: @output";
			next;
		}
	}

	return 1;

} # }}}

sub get_subvolumes { # {{{ - Get all subvolumes
	my $cmd 	= sprintf('/sbin/btrfs subvolume list -p %s | awk \'{print $9}\'',$snapshots);
	my @a 		= `$cmd`;
	chomp @a;
	my $success 	= $? >> 8;
	if ( not $success == 0 ) {
		say "Failed to get subvolumes!";
		say "Output was @a";
		return 0;
	}
	return @a;
} #}}}

sub usage { # {{{ - show usage
	warn <<EOM;

  $0 --help --cleanup

	Remove orphaned subvolumes
	If the process was canceled or there was a problem while building
	And the machine did not boot, the subvolume remain orphaned.

	This little tool is to remove it :)

EOM
	exit 0;
} # }}}

