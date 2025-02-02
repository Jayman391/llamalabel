#!/bin/sh
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=5:00:00
#SBATCH --mem=32G
#SBATCH --job-name=babycenter_labeling
#SBATCH --output=output/%x_%j.out
#SBATCH --mail-type=FAIL

curl -fsSL https://ollama.com/install.sh | sh

(ollama serve)

if [ $? -ne 0 ] ; then
    echo "Bad return"
    exit 9
fi

(ollama pull llama3.2)

# generate random alphanumeric string
rand_string() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
}

randstring=$(rand_string)

# for each input variable
for i in $@; do
    # add response to documents array in labels file
    curl http://localhost:11434/api/chat -d "$i" | jq '.response' >> labels/$(randstring).json
done