explain (analyse, costs, verbose, buffers, format json) with 
	recursive chain ( products, letter_bitmap, length ) as (
	
		with dictionary as (
	
			select distinct on ( word_product ) 
				word_product, 
				letter_bitmap, 
				length
			
			from word
			
			where
				2 <= length and length <= 26
				and '100' = character_bitmap
				and not has_double_letters
		
		)	
	
		select array[ word_product ], letter_bitmap::bit(26), length 	
		from dictionary
		
		union all
		
		select 
			array[ word_product ] || products,
			( dictionary.letter_bitmap | chain.letter_bitmap ) :: bit( 26 ),
			dictionary.length + chain.length
			
		from dictionary
		join chain on (
			( dictionary.length + chain.length ) <= 26
			and ( dictionary.letter_bitmap & chain.letter_bitmap ) = '0' :: bit( 26 )
		)
	
	)
	
	select * from chain; -- order by length desc;
	


	