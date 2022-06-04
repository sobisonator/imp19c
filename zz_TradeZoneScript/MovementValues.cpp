//Script to write movement script values.

#include <iostream>
#include <vector>
#include <fstream>
#include <iomanip>
#include <string>

using namespace std;

string capitalizeWord(string strToConvert)
{
    string temp;
    char temp_char;
    temp_char = toupper(strToConvert[0]);
    strToConvert[0] = temp_char;
    //remove underscore if it exists and capitalize second word.
    for(unsigned int i=0;i<strToConvert.length();i++)
    {
        if (strToConvert[i] == '_')
        {
            strToConvert[i] = ' ';
            temp_char = toupper(strToConvert[i + 1]);
            strToConvert[i + 1] = temp_char;
        }
    }
    return strToConvert;
}

void MovementConnectionScriptValues ()
{
    string trade_zone;
    string zones_from_file;
    vector<string> tradeZones;
    ofstream fw("script_values.txt", ofstream::out);
    if (fw.is_open())
    {
        ifstream input_file;
        input_file.open("inputf.in");
        while (zones_from_file != "DONE")
        {
            input_file >> zones_from_file;
            if (zones_from_file != "PRINT")
            {
                tradeZones.push_back(zones_from_file);
            }
            else if (zones_from_file == "PRINT")
            {
                for (int i = 0; i < tradeZones.size(); i++)
                {
                    fw << "---------------------------------------" << endl;
                    fw << "#Trade Zone: " << capitalizeWord(tradeZones.at(i)) << endl;
                    fw << "---------------------------------------" << endl;
                    for (int z = 0; z < tradeZones.size(); z++)
                    {
                        if ( tradeZones.at(z) != tradeZones.at(i))
                        {
                            fw << tradeZones.at(i) << "_to_" << tradeZones.at(z) << "_svalue = {" << endl;
                            fw << "    value = 100 #Base Value" << endl;
                            fw << "    subtract = " << tradeZones.at(i) << "_transportation_svalue" << endl;
                            fw << "    subtract = " << tradeZones.at(z) << "_transportation_svalue" << endl;
                            fw << "}" << endl;
                        }  
                    }                    
                }
            }
        }
        tradeZones.clear();
        fw.close();
    }          
}

void MovementScriptValues ()
{
    string trade_zone;
    string regions_from_file;
    vector<string> regions;
    ofstream fw("script_values_2.txt", ofstream::out);
    if (fw.is_open())
    {
        ifstream input_file;
        input_file.open("input_all.in");
        while (regions_from_file != "DONE")
        {
            input_file >> regions_from_file;
            if (regions_from_file == "START")
            {
                input_file >> trade_zone;
            }
            else if (regions_from_file != "PRINT")
            {
                regions.push_back(regions_from_file);
            }
            else if (regions_from_file == "PRINT")
            {
                fw << trade_zone << "_transportation_svalue = {" << endl;
                fw << "    value = 0" << endl;
                for (int i = 0; i < regions.size(); i++)
                {
                    fw << "    region:" << regions.at(i) << " = {" << endl;
                    fw << "        limit = {" << endl;
                    fw << "            any_region_province = {" << endl;
                    fw << "                OR = {" << endl;
                    fw << "                    any_neighbor_province = { has_road_towards = PREV }" << endl;
                    fw << "                    has_building = port_building" << endl;
                    fw << "                }" << endl;
                    fw << "            }" << endl;
                    fw << "        }" << endl;
                    fw << "        every_region_province = {" << endl;
                    fw << "            limit = {" << endl;
                    fw << "                any_neighbor_province = { has_road_towards = PREV }" << endl;
                    fw << "            }" << endl;
                    fw << "            add = railway_bonus" << endl;
                    fw << "        }" << endl;
                    fw << "        every_region_province = {" << endl;
                    fw << "            limit = {" << endl;
                    fw << "                has_building = port_building" << endl;
                    fw << "            }" << endl;
                    fw << "            add = port_bonus" << endl;
                    fw << "        }" << endl;
                    fw << "    }" << endl;
                }
                fw << "}" << endl;
            }
            if (regions_from_file == "CLEAR")
            {
                regions.clear();
            }
        }
        regions.clear();
        fw.close();
    }      
}

int main()
{
    MovementConnectionScriptValues();
    MovementScriptValues();
}
