# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..15\n"; }
END {print "not ok 1\n" unless $loaded;}
use Business::ISIN;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my $isin = new Business::ISIN;

# GB0004005475 is correct

my $testno = 1;
for (0..4) { 
    $testno++;
    $isin->set("GB000400547$_");
    if (defined $isin->get) { # check stringification
	print "not ok $testno\n";
	next;
    }
    print $isin->is_valid() ? "not ok $testno\n" : "ok $testno\n";
}

$testno++;
$isin->set(my $HSBC = "GB0004005475");
if ($isin->is_valid and $isin->get eq $HSBC and "$isin" eq $HSBC) {
    print "ok $testno\n";
} else {
    print "not ok $testno\n";
}

for (6..9) {
    $testno++;
    $isin->set("GB000400547$_");
    if (defined $isin->get) { # check stringification
	print "not ok $testno\n";
	next;
    }
    print $isin->is_valid() ? "not ok $testno\n" : "ok $testno\n";
}

# invalid country code

my @errors = (
['000invalid00' => "'000invalid00' is unparsable"],
['aa0000000000' => "Bad country code 'AA' in 'aa0000000000'"],
['gb0000000001' => "The check digit in 'gb0000000001' is inconsistent"],
);

foreach my $error (@errors) {
    $testno++;
    $isin->set( $error->[0] );
    if ($isin->is_valid ) {
	print "not ok $testno\n";
    } else {
	if ( $isin->error eq $error->[1] ) {
	    print "ok $testno\n";
	} else {
	    print "not ok $testno\n";
	    print "\$isin->error = (" . $isin->error . ")\n";
	    print "\$error->[1] = (" . $error->[1] . ")\n";
	}
    }
}

$testno++;
eval { Business::ISIN::check_digit( '00invalid00' )};
if ($@ =~ /^Invalid data: need 9 decimal digits/) {
    print "ok $testno\n";
} else {
    print "not ok $testno\n";
}
