use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Text::Context::EitherSide',
    'VERSION_FROM'	=> 'EitherSide.pm', # finds $VERSION
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'EitherSide.pm', # retrieve abstract from module
       AUTHOR     => 'Simon Cozens <simon@dsl.easynet.co.uk>') : ()),
);
