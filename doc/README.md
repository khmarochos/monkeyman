monkeyman
=========

```
Aye-aye-aye
Aye-aye-aye
Hugging up the big monkey man!
```

If you administrating CloudStack installations, you may find it useful.
If you love Perl5, you may consider it interesting.

I'm developing a library and some set of tools for managing
CloudStack-based infrastructure from the command line. It's going to
become a smart system for doing lots of administrative tasks, so it's
only the beginning for now. :-)

But what we have at the moment?

As about tools, we can do such things from UNIX-shell...

For example, let's assume you want to check state of the VM having
a certain IP-address AND being a member of a certain domain:

```
admin> mm_vm_info has_ipaddress=10.1.1.127 has_domain=A201306

<?xml version="1.0" encoding="UTF-8"?>
<listvirtualmachinesresponse>
  <virtualmachine>
    <id>99b885d4-70d7-4efc-8a4e-53417893fb19</id>
    <name>99b885d4-70d7-4efc-8a4e-53417893fb19</name>
	[...]
```

Or, if you want to, you can get certain parameters of this output:

```
admin> mm_vm_info has_ipaddress=10.1.1.127 has_domain=A201306 \
        -x //state -x //hostname -x //instancename

<state>Running</state>
<hostname>h2.c1.p1.z1.tucha13.net</hostname>
<instancename>i-51-135-VM</instancename>
```

You can reset the VM found by your desired criterias:

```
admin> mm_vm_reset has_instancename=i-13-666-VM

Want to listen to someone's network interface? No problem.

admin> mm_vm_tcpdump has_ipaddress=10.1.1.253
tcpdump: WARNING: vnet17: no IPv4 address assigned
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on vnet17, link-type EN10MB (Ethernet), capture size 65535 bytes
15:21:01.845886 IP 10.1.1.1.36686 > 10.1.1.253.imaps: Flags [S], seq 316746440, win 14600, options [mss 1460,sackOK,TS val 1959872931 ecr 0,nop,wscale 6], length 0
15:21:01.846023 IP 10.1.1.253.imaps > 10.1.1.1.36686: Flags [S.], seq 2234071684, ack 316746441, win 14480, options [mss 1460,sackOK,TS val 2579908884 ecr 1959872931,nop,wscale 6], length 0
```

^^^ The script just have found the hostname and the instance name,
logged into the host, analyzed output of "virsh dumpxml ...", found the
interface's name (vnet17) and launched tcpdump.

And you can use all these things not only from the command-line, as you
can use the object oriented library using all these things from your own
Perl5 scripts.

Let's assume you want to find and load all the information about some
domain:

```perl
    my $domain = eval { MonkeyMan::CloudStack::Elements::Domain->new(
	mm          => $mm,
	load_dom    => {
	    conditions  => {
		path        => 'ROOT/CUSTOMERS/ZALOOPA'
	    }
	}
    )};

    if($@) { $log->warn("Can't MonkeyMan::CloudStack::Elements::Domain->new(): $@"); next; }
```

Voila, now you have the corresponding object's reference in the $domain
variable. You can do some easy tricks with that domain. It's pretty easy
to get any parameter:

```perl
    my $domain_id = $domain->get_parameter('id');

    unless(defined($domain_id)) {
	$log->warn("Can't get the ID of the domain" .
	    ($domain->has_error ? (": " . $domain->error_message) : undef)
	);
	next;
    }
```

What if you want to get all volumes belongs to this domain? It's easy:

```perl
    my $volumz = $domain->find_related_to_me("volume");
    $log->logdie($domain->error_message) unless defined($volumz);
```

No kidding, you have the reference to the list of XML::LibXML documents
who have the <domainid> parameter corresponding to this domain. You can
easily initialize them as objects to do other cool things with these
volumes:

```perl
foreach my $volume_dom (@{ $volumz }) {

my $volume = eval { MonkeyMan::CloudStack::Elements::Volume->new(
    mm          => $mm,
    load_dom    => {
	 dom        => $volume_dom   # the XML document
    }
); };
if($@) { $log->warn("Can't MonkeyMan::CloudStack::Elements::Volume->new(): $@"); next; }
```

Oh, well, too much words... :-)

Would you like to use it? You're strongly welcome:
https://github.com/melnik13/monkeyman/

Would you like to develop it with me? Feel free to drop me a line:
v.melnik@tucha.ua
