=pod

=encoding utf-8

=head1 PURPOSE

Checks Moose type constraints, and L<MooseX::Types> type constraints are
picked up by C<dwim_type> from L<Type::Utils>.

=head1 DEPENDENCIES

Moose 2.0600 and MooseX::Types 0.35; skipped otherwise.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use strict;
use warnings;

use Test::More;
use Test::Requires { "Moose" => "2.0600" };
use Test::Requires { "MooseX::Types" => "0.35" };
use Test::TypeTiny;

use Moose;
use Moose::Util::TypeConstraints qw(:all);
use Type::Utils 0.015 qw(dwim_type);

# Creating a type constraint with Moose
subtype "Two", as "Int", where { $_ eq 2 };

my $two  = dwim_type("Two");
my $twos = dwim_type("ArrayRef[Two]");

isa_ok($two, 'Type::Tiny', '$two');
isa_ok($twos, 'Type::Tiny', '$twos');

should_pass(2, $two);
should_fail(3, $two);
should_pass([2, 2, 2], $twos);
should_fail([2, 3, 2], $twos);

# Creating a type constraint with MooseX::Types
{
	package MyTypes;
	use MooseX::Types -declare => ["Three"];
	use MooseX::Types::Moose "Int";
	
	subtype Three, as Int, where { $_ eq 3 };
}

# Note that MooseX::Types namespace-prefixes its types.
my $three = dwim_type("MyTypes::Three");
my $threes = dwim_type("ArrayRef[MyTypes::Three]");

TODO: {
	local $TODO = 'this probably needs fixing';
	isa_ok($three, 'Type::Tiny', '$three');
}

isa_ok($threes, 'Type::Tiny', '$threes');

should_pass(3, $three);
should_fail(4, $three);
should_pass([3, 3, 3], $threes);
should_fail([3, 4, 3], $threes);

done_testing;
