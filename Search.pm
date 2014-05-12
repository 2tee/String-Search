package String::Search;
use warnings;
use strict;
use Carp qw(croak);
use Config;
use File::Find qw(find);
use Exporter;

=head1 HEAD

String::Search - Search for String in different files

=head1 SYNOPSIS

    use String::Search qw(get_file_name);
    my ( $word, $directory ) = ( 'perl', '.');
    get_file_name( $word, $directory );

    use String::Search qw(get_line_name);
    my ( $word, $locate ) = ('perl', "*.pm");
    get_line_name( $word, $locate );

    use String::Search;

    find_file_name(\@ARGV);

=head1 DESCRIPTION

=head1 AUTHOR

 Timothy O. Adigun <2teezperl@gmail.com> 
=cut

our @ISA       = qw(Exporter);
our @EXPORT   = qw(find_file_name);
our @EXPORT_OK = qw(get_file_name get_line_name);
our %EXPORT_TAGS = (
   all  => [@EXPORT, @EXPORT_OK],
   file => [@EXPORT],
   get  => [@EXPORT_OK],
);

our $VERSION = '1.02';

BEGIN {
    my $msg = <<"_ERROR_";
    Currently running Perl Version $Config{'version'}
    You need to use Version 5.12.0 or better,
    Please Upgrade..."

_ERROR_

    croak $msg unless $] >= 5.012000;
}

my $err_msg_for_search   = q[Please specify word to search];
my $err_msg_for_location = q[Please specify a directory or directory_path];

sub get_file_name($$) {
    no warnings 'uninitialized';
    
    my ( $word, $location ) = @_;
    croak $err_msg_for_search
      unless defined $word;

    croak $err_msg_for_location
      if !-d $location;

    my $filename = {};

    _getter(
        $location,
        sub {
            $filename->{$File::Find::name}++
              if $_[0] =~ /\b$word\b/i;
        }
    );
    _report($filename);
}

sub get_line_name($$) {
    no warnings 'uninitialized';

    my ( $word, $location ) = @_;
    croak $err_msg_for_search
      unless defined $word;

    croak $err_msg_for_location
      unless defined $location;


    _getter(
        $_,
        sub {
            print $File::Find::name, $/, "Line ", $., ':', $_[0],$/
              if $_[0] =~ /\b$word\b/i;
        }
    ) for ( glob("$location") );
}

sub find_file_name{
   my $finder = shift;

   croak 'Parameter given is wrong, ARRAY ref must pass as parameter '
    unless ref $finder eq 'ARRAY';

   unless (!-d $finder->[1]){ 
   for my $f(glob("$finder->[0]")){
    find( sub {
	      print $File::Find::name,$/ if -e && -f && /$f/i;
	    }, $finder->[1]) ; 
   }
  }else{print 'Directory parameter is Wrong';}
}

sub _getter($&) {
    my ( $location, $word_to_search ) = @_;

    find(
        sub {
            if ( -e && -f ) {
                _reader( $_, $word_to_search );
            }
        },
        $location
    );

}

sub _reader {
    my ( $filename, $code_ref ) = @_;
    open my $fh, '<', $filename or die $!;
    while ( my $line = <$fh> ) {
        chomp $line;
        $code_ref->($line);
    }
}

sub _report {
    my $result = shift;
    if ( ref $result eq 'HASH' && %$result ) {
        my $total = values %$result;
        my $grammar =
          $total > 1 ? qq[These $total files] : qq[This $total file];
        print qq[$grammar matched the searched string \n],
          join $/ => map { $_ } keys %$result,
          ;
    }
    elsif ( !%$result ) { print 'No Report' }
    else                { croak 'Wrong Report' }

}

1;

