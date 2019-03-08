#!/usr/bin/env perl
use strict;
use warnings;

use Getopt::Long qw(GetOptions);
use Data::Dumper;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname( abs_path $0 ) . '/lib';

use CSFE;

if (csfe_check_all()) {
	my $username;
	GetOptions('username|u=s' => \$username) or die "Usage: $0 [--username|-u] USER\n";
	if (!$username) {
		die "Usage: $0 [--username|-u] USER\n";
	}
	my $res = csfe_post_request({
		defaultTier => 'tierIII',
		canExpand => 1,
		canReload => 1,
		cacheLevel => 'none',
		OSSFlag => 'CSFE_BASIC',
		widgetName => 'vps_info_new',
		username => $username,
		subsystemID => 3000,
		docPath => 'https://wiki.bizland.com/wiki/index.php/Widgets/vps_info_new',
		title => 'VPS Info',
		load_widget => 1,
		__got_widget_js => 1,
	});
	if ($res) {
		my @filtered = $res =~ m{<td><strong>(.*):</strong></td><td>(.*)</td>}g;
		my @host_node = $res =~ m{<td style=".*">\n\s+<strong>(Host Node):</strong>\n\s+</td>\n\s+<td>\n\s+(.*)};
		unshift @filtered, @host_node;
		for (my $i = 0; $i < @filtered; $i++) {
			if ($filtered[$i] =~ /<.*?>(.*)<.*>/) {
				$filtered[$i] = $1;
			}
			$filtered[$i] =~ s/^\s*(.*)\s*$/$1/;
		}
		my %info = @filtered;
		if (!$info{'IPs'}) {
			die "No VPS info was found! (Possibly shared account)\n";
		}
		print Dumper \%info;
	} else {
		die "Post request failed!\n";
	}
} else {
	die "Failed CSFE check_all().\n";
}

