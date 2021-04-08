#!/usr/bin/perl -w
use strict qw(vars subs);
use warnings;

my $username;
my $pid;
my $line;
my @whos = `who -u`;

foreach $line (@whos) {
	if ($line =~ /\(:0\)/) {
		print "line $line\n";
		$line =~ /^(\w*).*\s(\d*)\s.*/;
		$username = $1;
		$pid = $2; 
	}
}

my $dbus_address;

if ( open(FH, "<", "/proc/$pid/environ") ) {
	$dbus_address = do { local $/; <FH> };
	close FH;
} else {
	print "could not open\n";
}

print "dbus1: $dbus_address\n";

$dbus_address =~ /.*?(DBUS_SESSION_BUS_ADDRESS=unix:path=\/run\/user\/\d*\/bus).*/;
$dbus_address = $1;

print "name: $username pid: $pid\n";
print "dbus: $dbus_address\n";

#my $cmd = "sudo -u $username DISPLAY=:0 $dbus_address notify-send \"text\"";

my $cmd = "sudo -u pedro $dbus_address gdbus call --session --dest=org.freedesktop.Notifications --object-path=/org/freedesktop/Notifications --method=org.freedesktop.Notifications.Notify \"\" 0 \"\" 'Hello world!' 'This is an example notification.' '[]' '{\"urgency\": <1>}' 5000";

`$cmd`;

print "retvalue: $?\n";
