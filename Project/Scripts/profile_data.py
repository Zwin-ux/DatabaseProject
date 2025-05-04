import pandas as pd
import os

def main():
    # Locates  the CSV file if this is bad/cringe tell @mazen
    csv_path = os.path.join(os.path.dirname(__file__), '../Datasets/Data.csv')
    csv_path = os.path.abspath(csv_path)
    df = pd.read_csv(csv_path)

    print('--- Data Shape ---')
    print(df.shape)
    print('\n--- Columns ---')
    print(df.dtypes)
    print('\n--- Null Values ---')
    print(df.isnull().sum())
    print('\n--- Sample Rows ---')
    print(df.head(5))

    print('\n--- Unique Value Counts ---')
    for col in ['type', 'country', 'listed_in', 'director', 'rating']:
        print(f'\n{col}:')
        print(df[col].value_counts(dropna=False).head(10))

    print('\n--- Top Genres ---')
    genres = df['listed_in'].dropna().str.split(',')
    genre_flat = pd.Series([g.strip() for sublist in genres for g in sublist])
    print(genre_flat.value_counts().head(10))

    print('\n--- Top Countries ---')
    countries = df['country'].dropna().str.split(',')
    country_flat = pd.Series([c.strip() for sublist in countries for c in sublist])
    print(country_flat.value_counts().head(10))

    print('\n--- Top Directors ---')
    print(df['director'].value_counts().head(10))

    print('\n--- Duplicate Titles ---')
    print(df['title'][df['title'].duplicated()].unique())

    print('\n--- Data Profiling Complete ---')

if __name__ == '__main__':
    main()
