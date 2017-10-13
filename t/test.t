use Business::Isin;
use Test::More tests => 14;

my $isin = new Business::ISIN;

$isin->set("GB0004005475"); # right
ok($isin->is_valid);

$isin->set("GB0004005470"); # wrong
ok(not $isin->is_valid);

# Check of get and stringify

$isin->set("GB0004005475");
ok($isin->get eq "GB0004005475");

$isin->set("GB0004005475");
ok("$isin" eq "GB0004005475");



# Check of error messages

$isin->set("000invalid00");
ok($isin->error eq "'000invalid00' does not start with a 2-letter country code");

$isin->set("aa0000000000");
ok($isin->error eq "'aa0000000000' does not start with a 2-letter country code");

$isin->set("gb12%-oops90");
ok($isin->error eq "'gb12%-oops90' does not have characters 3-11 in [A-Za-z0-9]");

$isin->set("us123456789X");
ok($isin->error eq "'us123456789X' character 12 should be a digit");

$isin->set("gb0004005475hsbc2");
ok($isin->error eq "'gb0004005475hsbc2' has too many characters");

$isin->set("gb0000000001");
ok($isin->error eq "'gb0000000001' has an inconsistent check digit");



# Check of ISINs containing letters

$isin->set("AU0000ZELAM2");
ok($isin->is_valid);

$isin->set("US459056DG91");
ok($isin->is_valid);


# Check that set() returns an object

ok(($isin->set("US459056DG91")->is_valid));


# Check a file full of valid ISINs

open my $test, "t/test-isins.txt" or die "cannot open test-isins.txt: $!";
my @tests = map { chomp; $isin->set($_)->is_valid } <$test>;
ok(not grep { not $_ } @tests);


