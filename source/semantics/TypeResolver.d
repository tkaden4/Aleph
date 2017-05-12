module semantics.TypeResolver;

/* 
 * Performs all type inferencing
 */

import std.typecons;
import std.range;
import std.algorithm;
import std.stdio;
import std.string;

import syntax.tree;
import semantics;
import syntax.visit.Visitor;
import AlephException;
import util;

public auto resolveTypes(Tuple!(ProgramNode, AlephTable) t)
{
    return t.expand.resolveTypes;
}

public auto resolveTypes(ProgramNode node, AlephTable table)
in {
    assert(node);
    assert(table);
} out(t) {
    assert(t[0]);
    assert(t[1]);
} body {
    return alephErrorScope!("type resolver", {
        new TypeResolver().dispatch(node, table);
        return tuple(node, table);
    });
}

private class TypeResolver : Visitor!(void, AlephTable) {
protected:
    override void visit(ref VarDeclNode n, AlephTable t)
    {
        super.visit(n, t);
        auto sym = t.find(n.name).err(new Exception("Symbol %s not defined".format(n.name)));
        sym.type.match(
            (UnknownType _){
                sym.type = n.initVal.resultType;
                n.type = sym.type;
            },
            emptyFunc!Type
        );
    }

    override void visit(ref BlockNode node, AlephTable table)
    {
        super.visit(node, table);
        auto last = node.children.back;
        node.resultType = last.use!(x => x.resultType).or(PrimitiveType.Void);
    }

    override void visit(ref ProcDeclNode node, AlephTable table)
    {
        auto sym = table.find(node.name).err(new AlephException("Function %s not defined".format(node.name)));
        sym.match(
            (FunctionSymbol f){
                super.visit(node.bodyNode, f.bodyScope);
                node.returnType.match(
                    (UnknownType t){
                        node.returnType = node.bodyNode.resultType;
                        sym.type = node.functionType;
                    },
                    emptyFunc!Type
                );
            },
            (){ throw new AlephException("no function named %s".format(node.name)); }
        );
    }

    override void visit(ref CallNode node, AlephTable table)
    {
        auto x = node.toCall;
        super.visit(x, table);
        node.toCall = x;
        foreach(arg; node.arguments){
            super.visit(arg, table);
        }
        node.resultType.match(
            (UnknownType _){
                node.resultType = node.toCall.resultType.match(
                    (FunctionType ftype) => ftype.returnType,
                    (){ throw new AlephException("unable to call non-function"); }
                );
            },
            emptyFunc!Type
        );
    }

    override void visit(ref IdentifierNode node, AlephTable table)
    {
        auto sym = table.find(node.name).err(new AlephException("Identifier %s not defined".format(node.name)));
        node.resultType.match(
            (UnknownType t) => node.resultType = sym.type, 
            emptyFunc!Type
        );
    }
};
