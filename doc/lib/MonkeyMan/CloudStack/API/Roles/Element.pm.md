## `is_dom_expired()`

Requires the anonymous `Str` to be passed as the only parameter. Finds out if
the element's DOM expired and needs to be refreshed.

If it equals to '`never`', the method always returns false, so the DOM is
always being considered as up to date.

```perl
ok(!$self->is_dom_expired('never') );
```

If it equals to '`always`', the method always returns true, so the DOM is being
considered as outdated at any moment.

```perl
ok( $self->is_dom_expired('always') );
```

If it equals to some number (`N`), the method returns true if the DOM has been
refreshed not later than at `N` seconds of Unix Epoch, so it's considered as
expired.

```perl
# Let's assume it's 1000 seconds of Unix Epoch now
# and the DOM has been refreshed at 300
#
ok( $self->is_dom_expired(299) );
ok( $self->is_dom_expired(300) );
ok(!$self->is_dom_expired(301) );
```

If it equals to `+N`, the method returns true (expired) if the DOM update time
plus `N` is not greater than the current time.

```perl
# Let's assume it's 1000 seconds of Unix Epoch now
# and the DOM has been refreshed at 300
#
ok( $self->is_dom_expired('+699') );
ok( $self->is_dom_expired('+700') );
ok(!$self->is_dom_expired('+701') );
```

If equals to `-N`, the method returns true (expired) if the DOM has been
refreshed not less than N seconds ago.

```perl
# Let's assume it's 1000 seconds of Unix Epoch now
# and the DOM has been refreshed at 300
#
ok( $self->is_dom_expired('-701') );
ok( $self->is_dom_expired('-700') );
ok(!$self->is_dom_expired('-699') );
```
