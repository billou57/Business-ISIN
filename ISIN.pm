#######################################################################
# This package validates ISINs and calculates the check digit
#######################################################################

package Business::ISIN;
use Carp;
require 5.005;

use strict;
use vars qw($VERSION @country_codes);
$VERSION = '0.11';

use subs qw(check_digit);
use overload '""' => \&get; # "$isin" shows value


# List of valid two-letter country codes, as defined in ISO 3166
@country_codes = qw(
AD AE AF AG AI AL AM AN AO AQ AR AS AT AU AW AZ BA BB BD BE BF BG BH BI BJ
BM BN BO BR BS BT BV BW BY BZ CA CC CF CG CH CI CK CL CM CN CO CR CU CV CX
CY CZ DE DJ DK DM DO DZ EC EE EG EH ER ES ET FI FJ FK FM FO FR GA GB GD GE
GF GH GI GL GM GN GP GQ GR GT GU GW GY HK HM HN HR HT HU ID IE IL IN IO IQ
IR IS IT JM JO JP KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT
LU LV LY MA MC MD MG MH MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ NA
NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW
PY QA RE RO RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR ST SV SY SZ
TC TD TF TG TH TJ TK TM TN TO TP TR TT TV TW TZ UA UG UM US UY UZ VA VC VE
VG VI VN VU WF WS YE YT YU ZA ZM ZR ZW
);

#######################################################################
# Class Methods
#######################################################################

sub new {
    my $proto = shift;
    my $initializer = shift;

    my $class = ref($proto) || $proto;
    my $self = {value => undef, error => undef};
    bless ($self, $class);

    $self->set($initializer) if defined $initializer;
    return $self;
}

#######################################################################
# Object Methods
#######################################################################

sub set {
    my ($self, $isin) = @_;
    $self->{value} = $isin;
}

sub get {
    my $self = shift;
    return undef unless $self->is_valid;
    return $self->{value};
}

sub is_valid { # checks if self is a valid ISIN
    my $self = shift;
    return not defined $self->error;
}

sub error {
    # returns the error string resulting from failure of is_valid
    my $self = shift;

    return "'" . $self->{value} . "' is unparsable"
        unless $self->{value} =~ /^([A-Za-z]{2})([A-Za-z0-9]{9})([0-9])$/;

    return "Bad country code '" . uc($1) . "' in '" . $self->{value} . "'"
        unless grep {$_ eq uc $1} @country_codes;

    return "The check digit in '" . $self->{value} . "' is inconsistent"
	unless $3 == check_digit($1.$2);

    return undef;
}


#######################################################################
# Subroutines
#######################################################################

sub check_digit {
    # takes a 9 digit string, returns the "double-add-double" check digit
    my $data = uc shift;

    $data =~ /^[A-Z]{2}[A-Z0-9]{9}$/ or croak "Invalid data: $data";

    $data =~ s/([A-Z])/ord($1) - 55/ge; # A->10, ..., Z->35.

    my @n = split //, $data; # take individual digits

    my $max = scalar @n - 1;
    for my $i (0 .. $max) { if ($i % 2 == 0) { $n[$max - $i] *= 2 } }
    # double every second digit, starting from the RIGHT hand side.

    for my $i (@n) { $i = $i % 10 + int $i / 10 } # add digits if >=10

    my $sum = 0; for my $i (@n) { $sum += $i } # get the sum of the digits

    return (10 - $sum) % 10; # tens complement, number between 0 and 9
}

1;



__END__

=head1 NAME

Business::ISIN - validate International Securities Identification Numbers

=head1 SYNOPSIS

    use Business::ISIN;

    my $isin = new Business::ISIN 'US459056DG91';

    if ( $isin->is_valid ) {
	print "$isin is valid!\n";
	# or: print $isin->get() . " is valid!\n";
    } else {
	print "Invalid ISIN: " . $isin->error() . "\n";
	print "The check digit I was expecting is ";
	print Business::ISIN::check_digit('US459056DG9') . "\n";
    }

=head1 REQUIRES

Perl5, Carp

=head1 DESCRIPTION

C<Business::ISIN> is a class which validates ISINs (International Securities
Identification Numbers), the codes which identify shares in much the same
way as ISBNs identify books.  An ISIN consists of two letters, identifying
the country of origin of the security according to ISO 3166, followed by
nine characters in [A-Z0-9], followed by a decimal check digit.

The C<new()> method constructs a new ISIN object.  If you give it a scalar
argument, it will use the argument to initialize the object's value.  Here,
no attempt will be made to check that the argument is valid.

The C<set()> method sets the ISIN's value to a scalar argument which you
give.  Here, no attempt will be made to check that the argument is valid.

The C<get()> method returns a string, which will be the ISIN's value if it
is syntactically valid, and undef otherwise.  Interpolating the object
reference in double quotes has the same effect (see the synopsis).

The C<is_valid()> method returns true if the object contains a syntactically
valid ISIN.  (Note: this does B<not> guarantee that a security actually
exists which has that ISIN.) It will return false otherwise, i.e. if one of
the following is true:

=over 4

=item * The string does not consist of two letters followed by nine
characters in [A-Z0-9] followed by one decimal digit;

=item * The two letters are not a legal ISO 3166 country code (but case is
unimportant);

=item * The check digit does not correspond to the other eleven characterrs.

=back

If the string was not a syntactically valid ISIN, then the C<error()> method
will return a string explaining why not, i.e. which is the first of the
above reasons that applied.  Otherwise, C<error()> will return C<undef>.

C<check_digit()> is an ordinary subroutine and B<not> a class method.  It
takes a string of the first eleven characters of an ISIN as an argument (e.g.
"US459056DG9"), and returns the corresponding check digit, calculated using
the so-called 'double-add-double' algorithm.

=head1 DIAGNOSTICS

C<check_digit()> will croak with the message 'Invalid data' if you pass it
an unsuitable argument.

=head1 AUTHOR

David Chan <david@sheetmusic.org.uk>

=head1 COPYRIGHT

Copyright (C) 2001, David Chan. All rights reserved. This program is free
software; you can redistribute it and/or modify it under the same terms as
Perl itself.