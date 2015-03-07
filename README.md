Ruby7z is a VERY simple wrapper around p7zip since RubyZip was broken when I
came to test it out. Don't ask me why it was broken - it just was, but I needed
something to zip files even if it was quick and dirty.

As a simple wrapper you will need 7z installed and it is assumed to exist at:

   /usr/bin/7z.

Sorry, *nix only.

Given 7z hasn't been updated since 2010 hopefully the UI won't change too much
between versions but if it does, this wrapper works with:

   7-Zip 9.20 (c) Igor Pavlov

For examples see the specs.
