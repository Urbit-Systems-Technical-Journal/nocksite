#!/bin/bash

# Create intro.md (root page)
cat > intro.md << 'EOF'
# Nock Tutorial

Welcome to the Nock Tutorial! This interactive guide will teach you about the Nock instruction set architecture and combinator calculus.

## What is Nock?

Nock is a minimal combinator calculus that serves as the foundation for functional programming systems like Urbit. This tutorial provides multiple perspectives on understanding Nock, from theoretical foundations to practical implementation.

## How to Use This Tutorial

- **The Specification**: Start here to understand the core Nock operations
- **Understanding Nock**: Explore different mental models for thinking about Nock
- **Code Examples**: Interactive examples you can run and modify
- **Compiling**: How higher-level languages compile to Nock
- **Hints & Jetting**: Performance optimization techniques

Let's begin!
EOF

# Create _toc.yml
cat > _toc.yml << 'EOF'
format: jb-book
root: intro
title: Nock Tutorial
chapters:
- file: content/specification/index
  title: The Specification
  sections:
  - file: content/specification/detailed-examples
    title: Detailed Examples
    
- file: content/understanding/index
  title: Understanding Nock
  sections:
  - file: content/understanding/combinator-approach
    title: "Nock: The Combinator Approach"
  - file: content/understanding/turing-machine-approach
    title: "Nock: The Turing Machine Approach"
  - file: content/understanding/lambda-approach
    title: "Nock: The Lambda Approach"
  - file: content/understanding/assembly-language-approach
    title: "Nock: The Assembly Language Approach"
    
- file: content/examples/index
  title: Code Examples
  sections:
  - file: content/examples/nouns-and-data
    title: Nouns & Data
  - file: content/examples/combinators
    title: Combinators
  - file: content/examples/idioms-gates-patterns
    title: Idioms, Gates, & Design Patterns
    
- file: content/compiling/index
  title: Compiling
  sections:
  - file: content/compiling/relationship-to-hoon
    title: Relationship to Hoon
  - file: content/compiling/relationship-to-jock
    title: Relationship to Jock
    
- file: content/hints-jetting/index
  title: Hints & Jetting
  sections:
  - file: content/hints-jetting/algorithmic-considerations
    title: Algorithmic Considerations
EOF

# Create basic content for all markdown files
create_basic_md() {
    local file=$1
    local title=$2
    cat > "$file" << EOF
# $title

TODO: Add content for $title

This section is under development.
EOF
}

# Create all the markdown files
create_basic_md "content/specification/index.md" "The Specification"
create_basic_md "content/understanding/index.md" "Understanding Nock"
create_basic_md "content/examples/index.md" "Code Examples"
create_basic_md "content/compiling/index.md" "Compiling"
create_basic_md "content/compiling/relationship-to-hoon.md" "Relationship to Hoon"
create_basic_md "content/compiling/relationship-to-jock.md" "Relationship to Jock"
create_basic_md "content/hints-jetting/index.md" "Hints & Jetting"
create_basic_md "content/hints-jetting/algorithmic-considerations.md" "Algorithmic Considerations"

echo "All missing files created successfully!"
echo "You can now run: jupyter-book build ."
