#######################################################################
# This package validates ISINs and calculates the check digit
#######################################################################

package Business::ISIN;
use Carp;
require 5.000;

use strict;
use vars qw($VERSION @country_codes);
$VERSION = '0.01';

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
NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PT PW PY 
QA RE RO RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR ST SV SY SZ TC 
TD TF TG TH TJ TK TM TN TO TP TR TT TV TW TZ UA UG UM US UY UZ VA VC VE VG 
VI VN VU WF WS YE YT YU ZA ZM ZR ZW
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

sub set {
    my $self = shift;
    my $value = shift;
    $self->{value} = $value;
}

sub get {
    my $self = shift;
    return undef unless $self->is_valid;
    return $self->{value};
}

sub is_valid { # checks if self is a valid ISIN
    my $self = shift;

    unless ( $self->{value} =~ /^([A-Za-z]{2})(\d{9})(\d)$/ ) {
	$self->{error} = "'" . $self->{value} . "' is unparsable";
        return 0;
    }

    unless ( grep ($_ eq uc $1, @country_codes) ) {
	$self->{error} = "Bad country code '" . uc($1) .
				"' in '" . $self->{value} . "'";
        return 0;
    }

    unless ($3 eq check_digit($2)) { # inconsistent check digit
	$self->{error} = "The check digit in '" . $self->{value} .
				"' is inconsistent";
	return 0;
    }

    undef $self->{error};
    return 1;
}

sub error {
    # returns the error string resulting from failure of is_valid
    my $self = shift;
    return $self->{error};
}

#######################################################################
# Subroutines
#######################################################################

sub check_digit {
    # takes a 9 digit string, returns the "double-add-double" check digit
    my $data = shift;

    $data =~ /^\d{9}$/ or croak "Invalid data: need 9 decimal digits";

    my @n = split //, $data; # take individual digits

    for my $i ( @n[0, 2, 4, 6, 8] ) { $i *= 2 } # double every second digit

    for my $i ( @n[0..8] ) { $i = $i % 10 + int $i / 10 } # add digits if >=10

    my $sum = 0; for my $i (@n) { $sum += $i } # get the sum of the digits

    return 9 - ($sum % 10);
}

1;



__END__

=head1 NAME

Business::ISIN - validate International Securities Identification Numbers

=head1 SYNOPSIS

    use Business::ISIN;

    my $isin = new Business::ISIN;
    $isin->set('GB0004005474'); # last digit should be a '5'
    # or: my $isin = new Business::ISIN 'GB0004005474';

    if ( $isin->is_valid ) {
	print "$isin is valid!\n";
	# or: print $isin->get() . " is valid!\n";
    } else {
	print "Invalid ISIN: " . $isin->error() . "\n";
	print "The check digit I was expecting is ";
	print Business::ISIN::check_digit('000400547') . "\n";
    }

=head1 REQUIRES

Perl5, Carp

=head1 DESCRIPTION

C<Business::ISIN> is a class which validates ISINs (International Securities
Identification Numbers), the codes which identify shares in much the same
way as ISBNs identify books.  An ISIN consists of two letters, identifying
the country of origin of the security according to ISO 3166, followed by
nine decimal digits, followed by a decimal check digit.

The C<new()> method constructs a new ISIN object.  If you give it a scalar
argument, it will use the argument to initialize the object's value.  Here,
no attempt will be made to check that the argument is valid.

The C<set()> method sets the ISIN's value to the scalar argument which you
give.  Here, no attempt will be made to check that the argument is valid.

The C<get()> method returns a string, which will be the ISIN's value if it
is syntactically valid, and undef otherwise.  Interpolating the object
reference in double quotes has the same effect (see the synopsis).

The C<is_valid()> method returns true if the object contains a syntactically
valid ISIN.  (Note: this does B<not> guarantee that a security actually
exists which has that ISIN.) It will return false otherwise, i.e. if one of
the following is true:

=over 4

=item * The string does not consist of two letters followed by ten decimal
digits;

=item * The two letters are not a legal ISO 3166 country code (but case is
unimportant);

=item * The check digit does not correspond to the other nine digits.

=back

If the string was not a syntactically valid ISIN, then the C<error()> method
will return a string explaining why not, i.e. which is the first of the
above reasons that applied.  Otherwise, C<error()> will return C<undef>.

C<check_digit()> is an ordinary subroutine and B<not> a class method.  It
takes a string of 9 decimal digits as an argument, and returns the
corresponding check digit, calculated using the so-called
'double-add-double' algorithm.

=head1 DIAGNOSTICS

C<check_digit()> will croak with the message 'Invalid data: need 9 decimal
digits' if you pass it an unsuitable argument.

=head1 AUTHOR

David Chan <david@sheetmusic.org.uk>

=head1 COPYRIGHT

Copyright (C) 2001, David Chan. All rights reserved. This program is free
software; you can redistribute it and/or modify it under the same terms as
Perl itself.
