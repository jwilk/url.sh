#!/usr/bin/env perl

# Copyright © 2019 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

no lib '.';  # CVE-2016-1238

use strict;
use warnings;

use Cwd ();
use English qw(-no_match_vars);
use FindBin ();
use Test::More;
use autodie qw(open close);

use IO::Pty::Easy ();

my @templates = ('%s', '"%s"', "'%s'");
plan tests => scalar @templates;
my $basedir = "$FindBin::Bin/..";
open(my $fh, '<', "$basedir/README");
my ($url) = grep { /^https?:/ } <$fh>;
close($fh);
defined($url) or die;
chomp $url;
$ENV{PATH} .= ":$FindBin::Bin/ucowsay";
for my $template (@templates) {
    my $code = sprintf "true $template", $url;
    note("\$ $code");
    my $pty = IO::Pty::Easy->new;
    $pty->spawn('sh', '-c', $code);
    my $output = '';
    while ($pty->is_active) {
        $output .= $pty->read(1) // ''
    }
    $pty->close;
    note("$output\n");
    my $short_url = $url;
    $short_url =~ s{(https?://[^/]+/).*}{$1…};
    my $short_code = sprintf "true $template", $short_url;
    like($output, qr/< pwned >/, "«$short_code» code execution");
}

# vim:ts=4 sts=4 sw=4 et
