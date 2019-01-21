import SwiftSyntax
import Foundation

enum RemoveSideEffectsOperator {
    class Visitor: SyntaxVisitor, PositionDiscoveringVisitor {
        private(set) var positionsOfToken = [AbsolutePosition]()
        
        override func visit(_ node: CodeBlockItemSyntax) {
			super.visit(node)

			for statement in node.children where statementContainsMutableToken(statement) {
				let position = statement.endPosition
				positionsOfToken.append(position)
			}
		}

        private func statementContainsMutableToken(_ statement: Syntax) -> Bool {
            if isSpecialFunctionCall(statement) {
                return false
            }
            
            let doesntContainVariableAssignment = statement.children.count(variableAssignmentStatements) == 0
            let containsDiscardedResult = statement.description.contains("_ = ")
            let containsFunctionCall =  statement.children.count(functionCallStatements)   > 0
            let containsMemberAccess = statement.children.contains { $0 is MemberAccessExprSyntax} && statement.children.contains { $0 is FunctionCallArgumentListSyntax}

            return doesntContainVariableAssignment && (containsDiscardedResult || containsFunctionCall || containsMemberAccess)
        }

        private func variableAssignmentStatements(_ node: Syntax) -> Bool {
            return node is VariableDeclSyntax
        }

        private func functionCallStatements(_ node: Syntax) -> Bool {
            return node is FunctionCallArgumentListSyntax
        }

        private func isSpecialFunctionCall(_ node: Syntax) -> Bool {
            return node.description.contains("print") ||
                node.description.contains("fatalError") ||
                node.description.contains("exit") ||
                node.description.contains("abort")
        }
    }
}

extension RemoveSideEffectsOperator {
    class Rewriter: SyntaxRewriter, PositionSpecificRewriter {
        let positionToMutate: AbsolutePosition

        required init(positionToMutate: AbsolutePosition) {
            self.positionToMutate = positionToMutate
        }

        override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {

            guard let statements = node.body?.statements,
                let statementToExclude = statements.first(where: currentLineIsPositionToMutate) else {
                    return node
            }

            let mutatedFunctionStatements = statements.exclude { $0.description == statementToExclude.description }

            let newCodeBlockItemList = SyntaxFactory.makeCodeBlockItemList(mutatedFunctionStatements)
            let newFunctionBody = node.body!.withStatements(newCodeBlockItemList)

            return mutated(node, with: newFunctionBody)
        }

        private func currentLineIsPositionToMutate(_ currentStatement: CodeBlockItemSyntax) -> Bool {
            return currentStatement.endPosition.line == positionToMutate.line
        }

        private func mutated(_ node: FunctionDeclSyntax, with body: CodeBlockSyntax) -> DeclSyntax {
            return SyntaxFactory.makeFunctionDecl(attributes: node.attributes,
                                                  modifiers: node.modifiers,
                                                  funcKeyword: node.funcKeyword,
                                                  identifier: node.identifier,
                                                  genericParameterClause: node.genericParameterClause,
                                                  signature: node.signature,
                                                  genericWhereClause: node.genericWhereClause,
                                                  body: body)

        }
    }
}
