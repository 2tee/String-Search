
##String::Search - Search for String in different files

###SYNOPSIS

    use String::Search qw(get_file_name);
    my ( $word, $directory ) = ( 'perl', '.');
    get_file_name( $word, $directory );

    use String::Search qw(get_line_name);
    my ( $word, $locate ) = ('perl', "*.pm");
    get_line_name( $word, $locate );

    use String::Search;

    find_file_name(\@ARGV);

###DESCRIPTION

###AUTHOR

 Timothy O. Adigun <2teezperl@gmail.com> 

