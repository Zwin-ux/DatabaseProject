#ok fellas i might be stupid but im gonna keep trying, after class im gonna lock back in and continue on this


import pandas as pd
from sqlalchemy import create_engine, text
import re

# TALK TO MY TEAM ABOUT THIS REMEMBER MAZEN
DB_URL = 'mysql+pymysql://root:mason@localhost/MultimediaContentDB'
import os   
CSV_PATH = os.path.join(os.path.dirname(__file__), '../Datasets/Data.csv')
CSV_PATH = os.path.abspath(CSV_PATH)

def split_names(names):
    if pd.isna(names):
        return []
    return [n.strip() for n in re.split(r',|;', names) if n.strip()]

from datetime import datetime

def log_etl_metric(engine, job_name, start_time, end_time, rows_processed, status, error_message):
    with engine.connect() as conn:
        conn.execute(text('INSERT INTO etl_metrics (job_name, start_time, end_time, rows_processed, status, error_message) VALUES (:job_name, :start_time, :end_time, :rows_processed, :status, :error_message)'), {
            'job_name': job_name,
            'start_time': start_time,
            'end_time': end_time,
            'rows_processed': rows_processed,
            'status': status,
            'error_message': error_message
        })

def main():
    df = pd.read_csv(CSV_PATH)
    engine = create_engine(DB_URL)
    conn = engine.connect()
    countries = set()
    for c in df['country'].dropna():
        countries.update([x.strip() for x in c.split(',')])
    for country in countries:
        conn.execute(text('INSERT IGNORE INTO Country (name) VALUES (:name)'), {'name': country})
    genres = set()
    for g in df['listed_in'].dropna():
        genres.update([x.strip() for x in g.split(',')])
    for genre in genres:
        conn.execute(text('INSERT IGNORE INTO Genre (name) VALUES (:name)'), {'name': genre})
    directors = set(df['director'].dropna().unique())
    for director in directors:
        if director:
            conn.execute(text('INSERT IGNORE INTO User (name, email) VALUES (:name, :email)'), {'name': director, 'email': director.replace(' ','.').lower()+'@example.com'})
            conn.execute(text('INSERT IGNORE INTO Director (director_id) SELECT user_id FROM User WHERE name=:name'), {'name': director})
    actors = set()
    for cast in df['cast'].dropna():
        actors.update(split_names(cast))
    for actor in actors:
        if actor:
            conn.execute(text('INSERT IGNORE INTO User (name, email) VALUES (:name, :email)'), {'name': actor, 'email': actor.replace(' ','.').lower()+'@example.com'})
            conn.execute(text('INSERT IGNORE INTO Actor (actor_id) SELECT user_id FROM User WHERE name=:name'), {'name': actor})
    for _, row in df.iterrows():
        conn.execute(text('INSERT IGNORE INTO Content (title, description, release_year) VALUES (:title, :desc, :year)'), {
            'title': row['title'], 'desc': row['description'], 'year': row['release_year']
        })
        result = conn.execute(text('SELECT content_id FROM Content WHERE title=:title'), {'title': row['title']})
        content_id = result.scalar()
        # Link genres/coutnry/actor/director
        for genre in split_names(row['listed_in']):
            gid = conn.execute(text('SELECT genre_id FROM Genre WHERE name=:name'), {'name': genre}).scalar()
            if gid:
                conn.execute(text('INSERT IGNORE INTO Content_Genre (content_id, genre_id) VALUES (:cid, :gid)'), {'cid': content_id, 'gid': gid})
        for country in split_names(row['country']):
            cid = conn.execute(text('SELECT country_id FROM Country WHERE name=:name'), {'name': country}).scalar()
            if cid:
                conn.execute(text('INSERT IGNORE INTO Content_Country (content_id, country_id) VALUES (:cid, :ccid)'), {'cid': content_id, 'ccid': cid})
        if pd.notna(row['director']) and row['director']:
            did = conn.execute(text('SELECT user_id FROM User WHERE name=:name'), {'name': row['director']}).scalar()
            if did:
                conn.execute(text('INSERT IGNORE INTO Content_Director (content_id, director_id) VALUES (:cid, :did)'), {'cid': content_id, 'did': did})
        for actor in split_names(row['cast']):
            aid = conn.execute(text('SELECT user_id FROM User WHERE name=:name'), {'name': actor}).scalar()
            if aid:
                conn.execute(text('INSERT IGNORE INTO Content_Actor (content_id, actor_id) VALUES (:cid, :aid)'), {'cid': content_id, 'aid': aid})
    conn.close()
    print('ETL complete!')
if __name__ == '__main__':
    main()
