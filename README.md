# Any_Hash_Table.jai

This module acts as a wrapper around the default Table from Hash_Table.jai that allows you to do all the essential 
Table operations in a runtime-generic way. This should be helpful for those who want to support Tables in their 
(de)serialization libraries or in other applications that are doing funky reflection stuff.

## IMPORTANT NOTES

### Restrictions on given_hash_function and given_compare_function

If there is no given_compare_function for the table, memcmp is used instead of `operator ==`.
This should not matter for primitive types, but if you are using `#poke_name` to insert `operator ==` for other types, then compare_keys will not do what you want it to do!
Since `#poke_name` is going away anyhow, I see no reason to fix this. Just pass a `given_compare_function`.

Due to (what I believe to be) a small compiler bug, the procedure passed for `given_hash_function` and `given_compare_function` must not be polymorphic.
This means that if your key/value type is polymorphic, you may need to use `#procedure_of_call` to get the proper overload.

### Potential for breaking changes

Hash.HASH_INIT is duplicated here because it is #scope_file in the Hash module for some reason.
This means that if HASH_INIT is ever changed, it might silently break any code using this module!

Because we have to replicate all of the hash table procedures here with non-polymorphic versions, it is possible that changes to the base Hash_Table module could break compatibility with this module.
I will try to keep this module up-to-date and push patches as soon as possible if and when this occurs, but I think it is also important for you as the user to be aware of this.
Then at least, if you read the language changelog and see changes to the Hash_Table module, you will know to be on the lookout for strange memory bugs in code that uses hash tables!
