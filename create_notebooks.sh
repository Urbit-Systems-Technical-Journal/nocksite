#!/bin/bash

# Template for empty notebook
create_empty_notebook() {
    cat > "$1" << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# TODO: Add content"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.8.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF
}

# Create all the empty notebooks
create_empty_notebook "content/specification/detailed-examples.ipynb"
create_empty_notebook "content/understanding/combinator-approach.ipynb"
create_empty_notebook "content/understanding/turing-machine-approach.ipynb"
create_empty_notebook "content/understanding/lambda-approach.ipynb"
create_empty_notebook "content/understanding/assembly-language-approach.ipynb"
create_empty_notebook "content/examples/nouns-and-data.ipynb"
create_empty_notebook "content/examples/combinators.ipynb"
create_empty_notebook "content/examples/idioms-gates-patterns.ipynb"

echo "Empty notebooks created successfully!"
