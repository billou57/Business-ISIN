# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..12\n"; }
END {print "not ok 1\n" unless $loaded;}
use Business::ISIN;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my $isin = new Business::ISIN;


use vars qw($testno);
$testno = 2;
sub test { # ok if passed a true value
    my $ok = shift;   
    print $ok ? "ok $testno\n" : "not ok $testno\n";
    $testno++;
    return $ok;
}


# GB0004005475 is correct
# Check of is_valid

    $isin->set("GB0004005475"); # right
    test($isin->is_valid);

    $isin->set("GB0004005470"); # wrong
    test(not $isin->is_valid);

# Check of get and stringify

    $isin->set("GB0004005475");
    test($isin->get eq "GB0004005475");

    $isin->set("GB0004005475");
    test("$isin" eq "GB0004005475");

# Check of error messages

    $isin->set("000invalid00");
    test($isin->error eq "'000invalid00' is unparsable");

    $isin->set("aa0000000000");
    test($isin->error eq "Bad country code 'AA' in 'aa0000000000'");

    $isin->set("gb0000000001");
    test($isin->error eq "The check digit in 'gb0000000001' is inconsistent");

# Check of ISINs containing letters

    $isin->set("AU0000ZELAM2");
    test($isin->is_valid);
    
    $isin->set("US459056DG91");
    test($isin->is_valid);

# Check that set() returns an object
    test(($isin->set("US459056DG91")->is_valid));

# Check a file full of valid ISINs
open my $test, "test-isins.txt" or die "cannot open test-isins.txt: $!";
my @tests = map { chomp; $isin->set($_)->is_valid } <$test>;
test(not grep { not $_ } @tests);

