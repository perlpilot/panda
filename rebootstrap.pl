#!/usr/bin/env perl6
use v6;

my $home = $*OS eq 'MSWin32' ?? %*ENV<HOMEDRIVE> ~ %*ENV<HOMEPATH> !! %*ENV<HOME>;

if not "$home/.panda/state".IO.e {
    say "No need to rebootstrap, running normal bootstrap";
    run 'perl6 bootstrap.pl';
}

my @modules;

given open("$home/.panda/state") {
    for .lines() -> $line {
        my ($name, $state) = split /\s/, $line;
        next if $name eq any(<File::Tools JSON::Tiny Test::Mock panda>);
        if $state eq 'installed' {
            @modules.push: $name;
        }
    }
    .close;
}

# TODO: Make me cross-platform
shell 'rm -rf ~/.perl6/lib';
shell 'rm -rf ~/.panda';
shell 'perl6 bootstrap.pl';
shell "panda install @modules[]";