import os
import re
import pandas as pd
from IPython.display import display
import openai

# Constants
API_KEY = "YOUR_OPENAI_API_KEY"
INPUT_CSV = "/path/to/gpt_prompts_extra.csv"
OUTPUTS_FILE = "/path/to/gpt_hpo_annotations_extra.csv"

def initialise_openai_client(api_key):
    """initialise OpenAI client."""
    return openai.OpenAI(api_key=api_key)

def read_data(input_csv, outputs_file):
    """Read input data and previous outputs."""
    prompts = pd.read_csv(input_csv)
    outputs_df = pd.read_csv(outputs_file)
    return prompts, outputs_df

def process_prompts(prompts, outputs_df, client):
    """Process prompts and generate completions."""
    last_processed_index = outputs_df.index.max() + 1 if not outputs_df.empty else 0
    last_processed_index2 = (last_processed_index // 2) + 1
    
    for index, row in prompts.iloc[last_processed_index2:].iterrows():
        prompt_content = row['prompt']

        try:
            response = client.chat.completions.create(
                model='gpt-4',
                temperature=0,
                messages=[{'role': 'user', 'content': prompt_content}]
            )

            gpt_response = response.choices[0].message.content
            extracted_code = re.search(r'```python\n(.*?)\n```', gpt_response, re.DOTALL).group(1)
            exec(extracted_code)

            if isinstance(df, pd.DataFrame) and set(outputs_df.columns) == set(df.columns):
                df_sorted = df[outputs_df.columns]
                outputs_df = pd.concat([outputs_df, df_sorted], ignore_index=True)
                outputs_df.drop_duplicates().to_csv(OUTPUTS_FILE, index=False)

        except Exception as e:
            print(f"An error occurred for prompt at index {index}: {e}. Skipping to the next iteration.")

def main():
    """Main function."""
    # initialise OpenAI client
    client = initialise_openai_client(API_KEY)

    # Read data
    prompts, outputs_df = read_data(INPUT_CSV, OUTPUTS_FILE)

    # Process prompts
    process_prompts(prompts, outputs_df, client)

if __name__ == "__main__":
    main()
