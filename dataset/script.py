import pandas as pd
import sys

def create_constituency_region_map():
    """
    Create mapping based on URA Master Plan regions:
    North, Northeast, East, Central, West
    """
    return {
        # North Region
        'Ang Mo Kio': 'North',
        'Marsiling-Yew Tee': 'North',
        'Nee Soon': 'North',
        'Sembawang': 'North',
        'Yishun': 'North',
        'Kebun Baru': 'North',
        'Sembawang West': 'North',
        'Thomson': 'North',
        'Seletar': 'North',
        'Nee Soon Central': 'North',
        'Nee Soon South': 'North',
        'Nee Soon East': 'North',
        'Teck Ghee': 'North',
        'Cheng San': 'North',
        'Chong Boon': 'North',  # Added - part of Ang Mo Kio area

        # Northeast Region  
        'Pasir Ris-Punggol': 'North-East',
        'Punggol East': 'North-East',
        'Sengkang': 'North-East',
        'Tampines': 'North-East',
        'Punggol West': 'North-East',
        'Sengkang West': 'North-East',
        'Jalan Kayu': 'North-East',
        'Punggol': 'North-East',
        'Tampines Changkat': 'North-East',
        'Yio Chu Kang': 'North-East',
        'Upper Serangoon': 'North-East',
        'Paya Lebar': 'North-East',
        'Serangoon Gardens': 'North-East',
        'Punggol-Tampines': 'North-East',
        'Serangoon': 'North-East',
        'Pasir Ris': 'North-East',
        'Eunos': 'North-East',
        'Braddell Heights': 'North-East',  # Added - near Serangoon area
        'Bo Wen': 'North-East',  # Added - was in Serangoon area


        # East Region
        'Aljunied': 'East',
        'Bedok': 'East',
        'Changi-Simei': 'East',
        'East Coast': 'East',
        'Fengshan': 'East',
        'Hougang': 'East',
        'Marine Parade': 'East',
        'Marine Parade-Braddell Heights': 'East',
        'Pasir Ris-Changi': 'East',
        'Joo Chiat': 'East',
        'Siglap': 'East',
        'Changi': 'East',
        'Katong': 'East',
        'Kampong Chai Chee': 'East',
        'Geylang': 'East',
        'Geylang East': 'East',
        'Geylang Serai': 'East',
        'Geylang West': 'East',
        'Ulu Bedok': 'East',
        'Kaki Bukit': 'East',
        'Kampong Ubi': 'East',
        'Tanah Merah': 'East',
        'Kampong Kembangan': 'East',  # Added - near Kaki Bukit area


        # Central Region
        'Bishan-Toa Payoh': 'Central',
        'Bukit Timah': 'Central',
        'Holland-Bukit Timah': 'Central',
        'Jalan Besar': 'Central',
        'Kallang': 'Central',
        'MacPherson': 'Central',
        'Marymount': 'Central',
        'Moulmein': 'Central',
        'Mountbatten': 'Central',
        'Potong Pasir': 'Central',
        'Radin Mas': 'Central',
        'Tanjong Pagar': 'Central',
        'Toa Payoh': 'Central',
        'Cairnhill': 'Central',
        'Whampoa': 'Central',
        'Queenstown': 'Central',
        'Kampong Glam': 'Central',
        'Rochore': 'Central',
        'River Valley': 'Central',
        'Telok Ayer': 'Central',
        'Tanglin': 'Central',
        'Stamford': 'Central',
        'Bras Basah': 'Central',
        'Crawford': 'Central',
        'Farrer Park': 'Central',
        'Kampong Kapor': 'Central',
        'Havelock': 'Central',
        'Hong Lim': 'Central',
        'Kreta Ayer': 'Central',
        'Tiong Bahru': 'Central',
        'Boon Teck': 'Central',
        'Kim Keat': 'Central',
        'Kim Seng': 'Central',
        'Sepoy Lines': 'Central',
        'Kreta Ayer - Tanglin': 'Central',
        'Moulmein-Kallang': 'Central',
        'Henderson': 'Central',
        'Kolam Ayer': 'Central',
        'Pasir Panjang': 'Central',
        'Anson': 'Central',  # Added - was in the central business district area
        'Southern Islands': 'Central',  # Added - Sentosa, St John's Island, Kusu Island

        # West Region
        'Bukit Batok': 'West',
        'Bukit Panjang': 'West',
        'Choa Chu Kang': 'West',
        'Chua Chu Kang': 'West',
        'Holland-Bukit Panjang': 'West',
        'Hong Kah North': 'West',
        'Jurong': 'West',
        'Pioneer': 'West',
        'Tuas': 'West',
        'West Coast': 'West',
        'Bukit Gombak': 'West',
        'Jurong Central': 'West',
        'Jurong East-Bukit Batok': 'West',
        'West Coast-Jurong West': 'West',
        'Yuhua': 'West',
        'Delta': 'West',
        'Telok Blangah': 'West',
        'Ulu Pandan': 'West',
        'Alexandra': 'West',
        'Bukit Ho Swee': 'West',
        'Bukit Merah': 'West',
        'Brickworks': 'West',
        'Clementi': 'West',
        'Ayer Rajah': 'West',
        'Boon Lay': 'West',
        'Buona Vista': 'West',
        'Hong Kah': 'West',
        'Khe Bong': 'West',
        'Kuo Chuan': 'West',
        'Leng Kee': 'West',
        'Changkat': 'West',  # Added - was in Tampines area
    }

def add_region_column(input_file, output_file=None):
    """
    Add region column to CSV based on constituency mapping
    
    Args:
        input_file (str): Path to input CSV file
        output_file (str): Path to output CSV file (optional)
    """
    
    # Load the constituency-region mapping
    region_map = create_constituency_region_map()
    
    try:
        # Read the CSV file
        df = pd.read_csv(input_file)
        print(f"Loaded {len(df)} records from {input_file}")
        
        # Check if constituency column exists
        if 'constituency' not in df.columns:
            print("Error: 'constituency' column not found in CSV file")
            print(f"Available columns: {list(df.columns)}")
            return
        
        # Add region column
        df['region'] = df['constituency'].map(region_map)
        
        # Handle unknown constituencies
        unknown_constituencies = df[df['region'].isna()]['constituency'].unique()
        if len(unknown_constituencies) > 0:
            print(f"\nWarning: {len(unknown_constituencies)} unknown constituencies found:")
            for constituency in unknown_constituencies:
                print(f"  - {constituency}")
            
            # Fill unknown with 'Unknown'
            df['region'] = df['region'].fillna('Unknown')
        
        # Display summary
        print(f"\nRegion distribution:")
        region_counts = df['region'].value_counts()
        for region, count in region_counts.items():
            print(f"  {region}: {count} records")
        
        # Set output filename if not provided
        if output_file is None:
            output_file = input_file.replace('.csv', '_with_regions.csv')
        
        # Save the updated CSV
        df.to_csv(output_file, index=False)
        print(f"\nUpdated data saved to: {output_file}")
        
        # Display first few rows as preview
        print(f"\nPreview of updated data:")
        preview_cols = ['year', 'constituency', 'region', 'party', 'vote_count'] if all(col in df.columns for col in ['year', 'party', 'vote_count']) else df.columns.tolist()
        print(df[preview_cols].head().to_string(index=False))
        
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found")
    except Exception as e:
        print(f"Error processing file: {e}")

def main():
    """Main function to handle command line arguments"""
    
    if len(sys.argv) < 2:
        print("Usage: python script.py <input_csv_file> [output_csv_file]")
        
        return
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    add_region_column(input_file, output_file)

if __name__ == "__main__":
    main()
