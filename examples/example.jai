#import "Basic";
#import "Hash";
#import "Hash_Table";

#import,file "../module.jai";

/*
    I haven't written exhaustive tests, so if you run into any issues please send me a repro so that I can fix it an add a test case.
*/

main :: () {
    {
        section_header("basic functions");
        
        table: Table(string, int);
        any_table := Any_Table.from(table);
        
        init(*any_table);
        
        // table_add and table_set
        {
            table_add(*any_table, "three", 3);
            table_add(*any_table, "four", 4);
            
            table_add(*any_table, "five", 5);
            table_add(*any_table, "five", 55);
            
            table_add(*any_table, "seven", 6);
            table_set(*any_table, "seven", 7);
            
            for v, k: table {
                log("%: %", k, v);
            }
        }
        
        // table_find
        {
            sk := "four";
            ok, sv := table_find(*any_table, sk);
            if ok then log("table_find(%) -> %", sk, sv);
            else log("table_find(%) failed", sk);
        }
        
        // table_find_multiple before table_remove
        {
            sk := "five";
            sv := table_find_multiple(*any_table, sk);
            log("table_find_multiple(%) -> %", sk, sv);
        }
        
        // table_remove
        {
            k := "five";
            count_removed := table_remove_multiple(*any_table, k);
            log("table_remove(%) -> %", k, count_removed);
        }
        
        // table_find_multiple after table_remove
        {
            k := "five";
            v := table_find_multiple(*any_table, k);
            log("table_find_multiple(%) -> %", k, v);
        }
    }
    
    {
        section_header("struct value type");
        
        Foo :: struct {
            name: string;
            value: int;
        };
        
        table: Table(string, Foo);
        
        any_table := Any_Table.from(table);
        init(*any_table);
        
        foos := Foo.[
            .{ "one", 1 },
            .{ "three", 3 },
            .{ "seven", 7 },
        ];
        
        for foos {
            table_add(*any_table, it.name, it);
        }
        
        for v, k: table {
            log("%: %", k, v);
        }
    }
    
    {
        section_header("struct key type");
        
        Foo :: struct {
            name: string;
            value: int;
        };
        
        get_foo_hash :: (foo: Foo) -> u32 {
            return get_hash(foo.name);
        }
        
        operator == :: (a: Foo, b: Foo) -> bool {
            return memcmp(*a, *b, size_of(Foo)) == 0;
        }
        
        table: Table(Foo, string, 
            given_hash_function = get_foo_hash,
            given_compare_function = #procedure_of_call operator == (Foo.{}, Foo.{}),
        );
        
        any_table := Any_Table.from(table);
        init(*any_table);
        
        foos := Foo.[
            .{ "one", 1 },
            .{ "three", 3 },
            .{ "seven", 7 },
        ];
        
        for foos {
            table_add(*any_table, it, it.name);
        }
        
        for v, k: table {
            log("%: %", k, v);
        }
    }
    
    {
        section_header("array value type");
        
        My_Array :: [4] int;
        
        table: Table(int, My_Array);
        
        any_table := Any_Table.from(table);
        init(*any_table);
        
        arrays := My_Array.[
            .[ 1, 1, 1, 1 ],
            .[ 2, 2, 2, 2 ],
            .[ 3, 3, 3, 3 ],
        ];
        
        for arrays {
            table_add(*any_table, it[0], it);
        }
        
        for v, k: table {
            log("%: %", k, v);
        }
    }
    
    {
        section_header("array key type");
        
        My_Array :: [4] int;
        
        log("context.allocator: %", context.allocator);
        
        table: Table(My_Array, int, 
            given_compare_function = (a: My_Array, b: My_Array) -> bool {
                if a.count != b.count  return false;
                for 0..a.count-1  if a[it] != b[it]  return false;
                return true;
            }
        );
        
        any_table := Any_Table.from(table);
        init(*any_table);
        
        arrays := My_Array.[
            .[ 1, 1, 1, 1 ],
            .[ 2, 2, 2, 2 ],
            .[ 3, 3, 3, 3 ],
        ];
        
        for arrays {
            table_add(*any_table, it, it[0]);
        }
        
        for v, k: table {
            log("%: %", k, v);
        }
    }
    
    {
        section_header("primitive key types smaller than 8 bytes");
        
        table: Table(string, u8);
        any_table := Any_Table.from(table);
        
        init(*any_table);
        
        table_add(*any_table, "three", (3).(u8));
        table_add(*any_table, "four", (4).(u8));
        
        table_add(*any_table, "five", (5).(u8));
        table_add(*any_table, "five", (55).(u8));
        
        table_add(*any_table, "seven", (6).(u8));
        table_set(*any_table, "seven", (7).(u8));
        
        for v, k: table {
            log("%: %", k, v);
        }
    }
}


section_header :: (text: string) {
    write_string("\n=== ");
    write_string(text);
    write_string(" ===\n");
}