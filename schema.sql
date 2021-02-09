create or replace function normalize_word( word text )
    returns text
    language sql
    immutable
as
    $$

        --
        -- Although there is an unaccent contrib extention the unaccent function itself is not pure
        -- which means it can't be used in a generated column. I am fully aware of the fact that
        -- depending on your local the output may be different but in this case I don't care. I just
        -- want some easy letters to compare.
        --

        -- We are going to lower the word and replace all the accents with just the regular letter
        -- The replace was taken from the pg wiki: https://wiki.postgresql.org/wiki/Strip_accents_from_strings,_and_output_in_lowercase

        select translate(
            lower( word ),
            'áàâãäåāăąèééêëēĕėęěìíîïìĩīĭḩóôõöōŏőùúûüũūŭůäàáâãåæçćĉčöòóôõøüùúûßéèêëýñîìíïş',
            'aaaaaaaaaeeeeeeeeeeiiiiiiiihooooooouuuuuuuuaaaaaaeccccoooooouuuuseeeeyniiiis'
        );

    $$
;

create or replace function split_word( word text ) 
    returns table ( letter text ) 
    language sql 
    immutable
as 
    $$

        select * from regexp_split_to_table( word, '' );

    $$
;

create or replace function letter_number( word text ) 
    returns table( letter text, number integer )
    language sql 
    immutable
as 
    $$

        select letter, number 
        from split_word( word )
        join 
            ( values 
            
                ( 'a',   2 ), ( 'b',   3 ), ( 'c',   5 ),
                ( 'd',   7 ), ( 'e',  11 ), ( 'f',  13 ),
                ( 'g',  17 ), ( 'h',  19 ), ( 'i',  23 ),
                ( 'j',  29 ), ( 'k',  31 ), ( 'l',  37 ),
                ( 'm',  41 ), ( 'n',  43 ), ( 'o',  47 ),
                ( 'p',  53 ), ( 'q',  59 ), ( 'r',  61 ),
                ( 's',  67 ), ( 't',  71 ), ( 'u',  73 ),
                ( 'v',  79 ), ( 'w',  83 ), ( 'x',  89 ),
                ( 'y', 101 ), ( 'z', 103 )
    
            ) 
            as letter_number( letter, number ) using ( letter );

    $$
;

create or replace function has_double_letters( word text ) 
    returns boolean 
    language sql 
    immutable
as 
    $$
    
        select char_length( word ) <> ( select count( distinct letter ) from split_word( word ) );

    $$ 
;

create or replace function character_bitmap( word text )
    returns bit(3)
    language sql
    immutable
as
    $$

        select ''
            || ( word ~ '[a-z]' ) :: integer :: bit( 1 )
            || ( word ~ '[0-9]' ) :: integer :: bit( 1 )
            || ( word ~ '[^a-z0-9]' ) :: integer :: bit( 1 )
            ;;

    $$
;

create or replace function letter_bitmap( word text ) 
    returns bit(26) 
    language sql 
    immutable
as
    $$

        select ''
            || ( word ~ 'a' ) :: integer :: bit( 1 ) 
            || ( word ~ 'b' ) :: integer :: bit( 1 ) 
            || ( word ~ 'c' ) :: integer :: bit( 1 )
            || ( word ~ 'd' ) :: integer :: bit( 1 ) 
            || ( word ~ 'e' ) :: integer :: bit( 1 ) 
            || ( word ~ 'f' ) :: integer :: bit( 1 )
            || ( word ~ 'g' ) :: integer :: bit( 1 ) 
            || ( word ~ 'h' ) :: integer :: bit( 1 ) 
            || ( word ~ 'i' ) :: integer :: bit( 1 )
            || ( word ~ 'j' ) :: integer :: bit( 1 ) 
            || ( word ~ 'k' ) :: integer :: bit( 1 ) 
            || ( word ~ 'l' ) :: integer :: bit( 1 )
            || ( word ~ 'm' ) :: integer :: bit( 1 ) 
            || ( word ~ 'n' ) :: integer :: bit( 1 ) 
            || ( word ~ 'o' ) :: integer :: bit( 1 )
            || ( word ~ 'p' ) :: integer :: bit( 1 ) 
            || ( word ~ 'q' ) :: integer :: bit( 1 ) 
            || ( word ~ 'r' ) :: integer :: bit( 1 )
            || ( word ~ 's' ) :: integer :: bit( 1 ) 
            || ( word ~ 't' ) :: integer :: bit( 1 ) 
            || ( word ~ 'u' ) :: integer :: bit( 1 )
            || ( word ~ 'v' ) :: integer :: bit( 1 ) 
            || ( word ~ 'w' ) :: integer :: bit( 1 ) 
            || ( word ~ 'x' ) :: integer :: bit( 1 )
            || ( word ~ 'y' ) :: integer :: bit( 1 ) 
            || ( word ~ 'z' ) :: integer :: bit( 1 )
            ;;

    $$
;

create or replace function word_product( word text ) 
    returns bigint 
    language sql 
    immutable
as
    $$

        select exp( sum( ln( number ) ) ) from letter_number( word )

    $$
;

drop table if exists word;
create table word (

    word_id             serial primary key,
    word                text,
    normalized          text    generated always as ( normalize_word( word ) ) stored,
    length              integer generated always as ( char_length( normalize_word( word ) ) ) stored,
    has_double_letters  boolean generated always as ( has_double_letters( normalize_word( word ) ) ) stored,
    character_bitmap    bit(3)  generated always as ( character_bitmap( normalize_word( word ) ) ) stored,
    letter_bitmap       bit(26) generated always as ( letter_bitmap( normalize_word( word ) ) ) stored,
    word_product        bigint  generated always as ( word_product( normalize_word( word ) ) ) stored

);