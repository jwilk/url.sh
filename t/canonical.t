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

use URI ();

plan tests => 1;
my $basedir = "$FindBin::Bin/..";
open(my $fh, '<', "$basedir/README");
my ($url) = grep { /^https?:/ } <$fh>;
close($fh);
defined($url) or die;
chomp $url;
note($url);
my $uri = URI->new($url);
cmp_ok($url, 'eq', $uri->canonical, 'URL in canonical form');

# vim:ts=4 sts=4 sw=4 et
