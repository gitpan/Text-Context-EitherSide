package Text::Context::EitherSide;

use 5.006;
use strict;
use warnings;
use Carp;

require Exporter;
our @ISA=qw(Exporter);
our @EXPORT_OK = qw(get_context);

use constant DEFAULT_WORDS => 2;

our $VERSION = '1.0';

sub get_context {
    my ($n, $string, @words) = @_;
    Text::Context::EitherSide->new($string, context => $n)->as_string(@words);
}

sub new {
    my $class = shift;
    my $text = shift or carp "No text supplied for context search";
    my %args = @_;

    return bless {  
        n => exists $args{context}? $args{context}: DEFAULT_WORDS,
        text => $text
    }, $class;
}

sub context { 
    my $self = shift;
    $self->{n} = shift if @_;
    return $self->{n};
}

sub as_sparse_list {
    my $self = shift;
    my @words = @_;
       my %keywords = map { $_ => 1 }
        map { split /\s/, $_ } @words;    # Decouple phrases

    # First, split the string into words
    my @split_s = split /\s+/, $self->{text};

    # Now, locate keywords and "mark" the indices we want.
    my @marks = (undef)x @split_s;
    my $ok=0;
    for (0 .. $#split_s) {
        if (exists $keywords{ $split_s[$_] }) {
            $ok++;
            # Mark it and its $n neighbours.
            $marks[$_] = $split_s[$_] for grep { $_ >= 0 and $_ <= $#split_s }
                $_ - $self->{n} .. $_ + $self->{n};
        }
    }

    return $ok? @marks : ();
}

sub as_list {
    my $self = shift;
    my @sparse = $self->as_sparse_list(@_);
    return () unless @sparse;
    my @ret;
    for (0..$#sparse) {
        if (defined $sparse[$_]) {
            push @ret, $sparse[$_];
        } else {
            push @ret, "..." unless @ret and $ret[-1] eq "...";
        }
    }
    return @ret;
}       
 
sub as_string {
    my $self = shift;
    return(join" ",$self->as_list(@_));;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Text::Context::EitherSide - Get n words either side of search keywords

=head1 SYNOPSIS

  use Text::Context::EitherSide;

  my $text = "The quick brown fox jumped over the lazy dog";
  my $context = Text::Context::EitherSide->new($text);

  $context->as_string("fox") # "... quick brown fox jumped over ..."

  $context->as_string("fox", "jumped") 
    # "... quick brown fox jumped over the ..."
  
  my $context = Text::Context::EitherSide->new($text, context => 1);
    # 1 word on either side
  
  $context->as_string("fox", "jumped", "dog");
    # "... brown fox jumped over ... lazy dog",

Or, if you don't believe in all this OO rubbish:

  use Text::Context::EitherSide qw(get_context);
  get_context(1, $text, "fox", "jumped", "dog") 
        # "... brown fox jumped over ... lazy dog"

=head1 DESCRIPTION

Suppose you have a large piece of text - typically, say, a web page or a
mail message. And now suppose you've done some kind of full-text search
on that text for a bunch of keywords, and you want to display the
context in which you found the keywords inside the body of the text.

A simple-minded way to do that would be just to get the two words either
side of each keyword. But hey, don't be too simple minded, because
you've got to make sure that the list doesn't overlap. If you have

    the quick brown fox jumped over the lazy dog

and you extract two words either side of "fox", "jumped" and "dog", you
really don't want to end up with 

    quick brown fox jumped over brown fox jumped over the the lazy dog

so you need a small amount of smarts. This module has a small amount of
smarts.

=head1 METHODS

This is primarily an object-oriented module. If you don't care about
that, just import the C<get_context> subroutine, and call it like so:
    
    get_context($num_of_words, $text, @words_to_find)

and you'll get back a string with ellipses as in the synopsis. That's
all that most people need to know. But if you want to do clever stuff...

=head2 new

    my $c = Text::Context::EitherSite->new($text [, context=> $n]);

Create a new object storing some text to be searched, plus optionally
some information about how many words on either side you want. (If you
don't like the default of 2.)

=head2 context

    $c->context(5);

Allows you to get and set the number of the words on either side.

=head2 as_sparse_list

    $c->sparse_list(@keywords)

Returns the keywords, plus I<n> words on either side, as a sparse list;
the original text is split into an array of words, and non-contextual
elements are replaced with C<undef>s. (That's not actually how it works,
but conceptually, it's the same.)

=head2 as_list

    $c->as_list(@keywords)

The same as C<as_sparse_list>, but single or multiple C<undef>s are
collapsed into a single ellipsis:

    (undef, "foo", undef, undef, undef, "bar")

becomes 

    ("...", "foo", "...", "bar")

=head2 as_string

    $c->as_string(@keywords)

Takes the C<as_list> output above and joins them all together into a
string. This is what most people want from C<Text::Context::EitherSide>.

=head2 EXPORT

C<get_context> is available as a shortcut for

   Text::Context::EitherSide->new($text, context => $n)->as_string(@words);

but needs to be explicitly imported. Nothing is exported by default.

=head1 SEE ALSO

L<Text::Context> is an even smarter way of extracting a contextual
string.

=head1 COPYRIGHT AND LICENSE

Copyright 2002 by Kasei Limited, http://www.kasei.com/

You may use and redistribute this module under the terms of the
Artistic License.

=cut
