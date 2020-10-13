use strict;
use warnings;
use Test::More;
use Test::Snapshot;

use GraphViz2;
use GraphViz2::Parse::ISA;
use Algorithm::Dependency;
use Algorithm::Dependency::Source::HoA;

my $g = GraphViz2->new;
my $data = {
  'Adult'                    => [],
  'Adult::Child1'            => [qw/Adult/],
  'Adult::Child2'            => [qw/Adult/],
  'Adult::Child::Grandchild' => [qw/Adult::Child1 Adult::Child2/],
};
my $d = Algorithm::Dependency->new(
    source => Algorithm::Dependency::Source::HoA->new($data)
);
die 'Error: No dependency data provided' if !$d;

for my $item (sort {$a->id cmp $b->id} $d->source->items) {
    $g->add_node(name => $item->id);
    $g->add_edge(from => $item->id, to => $_) for $item->depends;
}

is_deeply_snapshot $g->node_hash, 'nodes dep';
is_deeply_snapshot $g->edge_hash, 'edges dep';

my $g_isa = GraphViz2::Parse::ISA->new;
unshift @INC, 't/lib';
$g_isa->add(class => 'Adult::Child::Grandchild', ignore => []);
$g_isa->add(class => 'HybridVariety', ignore => []);
$g_isa->generate_graph;

$g = $g_isa->graph;
is_deeply_snapshot $g->node_hash, 'nodes isa';
is_deeply_snapshot $g->edge_hash, 'edges isa';

done_testing;
