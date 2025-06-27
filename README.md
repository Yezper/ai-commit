# ai-commit
A tool to generate commit messages using Open AI.

## Installation

Clone the repository:

```
git clone git@github.com:Yezper/ai-commit.git
```

Link the scripts to your user's bin directory, or somewhere else in your PATH:

```
sudo ln -s $(pwd)/ai-commit ~/bin/ai-commit
sudo ln -s $(pwd)/ai-commit-msg ~/bin/ai-commit-msg
```

Add +x permission to the scripts:

```
chmod +x ~/bin/ai-commit
chmod +x ~/bin/ai-commit-msg
```

## Configuration

Set your OpenAI API key in the environment variable in `~/.zshrc` or `~/.bashrc`:

```
export OPENAI_API_KEY=your_openai_api_key
```

Set the `SLURP_FILE` variable in `ai-commit-msg`. Default is `~/tmp/ai-commit-msg.slurp`
if `~/tmp` exists, otherwise we'll default to `/tmp/ai-commit-msg.slurp`.
