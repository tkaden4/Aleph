module semantics.actions.Desugar;

import std.stdio;
import std.range;
import std.typecons;
import std.algorithm : each;
import std.meta;

import semantics.symbol;
import util;
import syntax;

public auto desugar(Tuple!(ProgramNode, AlephTable) node)
{
    return tuple(node[0].desugar, node[1]);
}


public ProgramNode desugar(ProgramNode node)
in {
    assert(node);
} body {
    return DesugarProvider!(DesugarProvider).visit(node);
}

template DesugarProvider(alias Provider, Args...){
    ProcDeclNode visit(ProcDeclNode node)
    {
        node.bodyNode = node.bodyNode.match(
            (BlockNode node) => node,
            (ExpressionNode node) => new BlockNode([node])
        ).then!(
            (x){
                x.children.back = x.children.back.match(
                    identity!StatementNode,
                    (ExpressionNode exp) => new ReturnNode(exp)
                );
            }
        );
        return DefaultProvider!(Provider, Args).visit(node);
    }

    T visit(T)(T t, Args args)
    {
        return DefaultProvider!(Provider, Args).visit(t, args);
    }
};
