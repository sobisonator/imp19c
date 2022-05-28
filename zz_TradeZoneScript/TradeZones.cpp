//Trade Zone script generator for Imp19C, this is used to write all kinds of repetative scripts for tradezones.
// There are 2 input files, inputf and input_all.
//inputf holds all trade zones and their regions.
//input_all is just all trade zones.

//NOTE: If regions or zones are changed in the future
//      just change the 2 Input files to match the current setup then run this script to get all the files again.

#include <iostream>
#include <vector>
#include <fstream>
#include <iomanip>
#include <string>

using namespace std;

void ScriptedTriggers()
{
    string trade_zone;
    string regions_from_file;
    vector<string> regions;
    ofstream fw("scripted_triggers.txt", ofstream::out);

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
                fw << trade_zone << "_tradezone = {" << endl;
                fw << "    trigger_if = {" << endl;
                fw << "        limit = {" << endl;
                fw << "            $PROVINCE$ = yes" << endl;
                fw << "        }" << endl;
                fw << "        OR = {" << endl;
                for (int i = 0; i < regions.size(); i++) {
                    fw << "            is_in_region = " << regions.at(i);
                    fw << endl;
                }
                fw << "        }" << endl;
                fw << "    }" << endl;
                fw << "    trigger_else = {" << endl;
                fw << "        limit = {" << endl;
                fw << "            $PROVINCE$ = no" << endl;
                fw << "        }" << endl;
                fw << "        OR = {" << endl;
                for (int i = 0; i < regions.size(); i++) {
                    fw << "            this = region:" << regions.at(i);
                    fw << endl;
                }
                fw << "        }" << endl;
                fw << "    }" << endl;
                fw << "}" << endl;
            }
            if (regions_from_file == "CLEAR")
            {
                regions.clear();
            }
        }
        regions.clear();
        cout << "\nScripted Triggers has been generated successfully.\n";
        fw.close();
    }
}

void GoodsProducedScriptValues ()
{
    string trade_zone;
    string regions_from_file;
    vector<string> regions;
    ofstream fw("script_values.txt", ofstream::out);
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
                fw << trade_zone << "_total_goods = {" << endl;
                fw << "    value = 0" << endl;
                for (int i = 0; i < regions.size(); i++) {
                    fw << "    region:" << regions.at(i) << " = {" << endl;
                    fw << "        every_region_province = {" << endl;
                    fw << "            add = num_goods_produced" << endl;
                    fw << "        }" << endl;
                    fw << "    }";
                    fw << endl;
                }
                fw << "}" << endl;
            }
            if (regions_from_file == "CLEAR")
            {
                regions.clear();
            }
        }
        regions.clear();
        cout << "\nScript Values have been generated successfully.\n";
        fw.close();
    }
}

void PopulationScriptValues ()
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
                fw << trade_zone << "_total_population = {" << endl;
                fw << "    value = 0" << endl;
                for (int i = 0; i < regions.size(); i++) {
                    fw << "    region:" << regions.at(i) << " = {" << endl;
                    fw << "        every_region_province = {" << endl;
                    fw << "            add = total_population" << endl;
                    fw << "        }" << endl;
                    fw << "    }";
                    fw << endl;
                }
                fw << "}" << endl;
            }
            if (regions_from_file == "CLEAR")
            {
                regions.clear();
            }
        }
        regions.clear();
        cout << "\nScript Values have been generated successfully.\n";
        fw.close();
    }
}

void CustomLoc ()
{
    string zones_from_file;
    vector<string> tradeZones;
    ofstream fw("custom_loc.txt", ofstream::out);
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
                fw << "state_trade_zone_loc = {" << endl;
                fw << "    type = province" << endl << endl;
                for (int i = 0; i < tradeZones.size(); i++) {
                    fw << "    text = {" << endl;
                    fw << "        localization_key = state_trade_zone_loc_" << i + 1 << endl;
                    fw << "        trigger = {" << endl;
                    fw << "            " << tradeZones.at(i) << "_tradezone = { PROVINCE = yes }" << endl;
                    fw << "        }" << endl;
                    fw << "    }" << endl;
                }
                fw << "    text = {" << endl;
                fw << "        localization_key = state_trade_zone_loc_fallback" << endl;
                fw << "        trigger = {" << endl;
                fw << "            always = yes" << endl;
                fw << "        }" << endl;
                fw << "    }" << endl;
                fw << "}" << endl;
                //Second Loc
                fw << "state_trade_zone_value_loc = {" << endl;
                fw << "    type = province" << endl << endl;
                //loop to fill the OR statement with vector
                for (int i = 0; i < tradeZones.size(); i++) {
                    fw << "    text = {" << endl;
                    fw << "        localization_key = state_trade_zone_value_loc_" << i + 1 << endl;
                    fw << "        trigger = {" << endl;
                    fw << "            " << tradeZones.at(i) << "_tradezone = { PROVINCE = yes }" << endl;
                    fw << "        }" << endl;
                    fw << "    }" << endl;
                }
                fw << "    text = {" << endl;
                fw << "        localization_key = state_trade_zone_value_loc_fallback" << endl;
                fw << "        trigger = {" << endl;
                fw << "            always = yes" << endl;
                fw << "        }" << endl;
                fw << "    }" << endl;
                fw << "}" << endl;
            }
            if (zones_from_file == "CLEAR")
            {
                tradeZones.clear();
            }
        }
        tradeZones.clear();
        cout << "\nCustom Loc have been generated successfully.\n";
        fw.close();
    }    
}

void Localization ()
{
    string trade_zone;
    string zones_from_file;
    vector<string> tradeZones;
    ofstream fw("localization.yml", ofstream::out);
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
                for (int i = 0; i < tradeZones.size(); i++) {
                    fw << "state_trade_zone_loc_" << i + 1 << ":0 \"" << tradeZones.at(i) << "\"\n";
                }
                fw << "state_trade_zone_loc_fallback:0 \"0\"" << "\n\n\n";
                for (int i = 0; i < tradeZones.size(); i++) {
                    fw << "state_trade_zone_value_loc_" << i + 1 << ":0 \"";
                    fw << "[GuiScope.SetRoot( Player.MakeScope ).ScriptValue('" << tradeZones.at(i) <<  "_total_goods')|0]";
                    fw << "\"\n";
                }
                fw << "state_trade_zone_value_loc_fallback:0 \"0\"" << "\n\n\n";
            }
            if (zones_from_file == "CLEAR")
            {
                tradeZones.clear();
            }
        }
        tradeZones.clear();
        cout << "\nLocalization has been generated successfully.\n";
        fw.close();
    }
}

void SetupEvent ()
{
    string trade_zone;
    string zones_from_file;
    vector<string> tradeZones;
    ofstream fw("setup_event.txt", ofstream::out);
    if (fw.is_open())
    {
        ifstream input_file;
        input_file.open("inputf.in");
        while (zones_from_file != "DONE")
        {
            input_file >> zones_from_file;
            if (zones_from_file == "START")
            {
                input_file >> trade_zone;
            }
            else if (zones_from_file != "PRINT")
            {
                tradeZones.push_back(zones_from_file);
            }
            else if (zones_from_file == "PRINT")
            {
                for (int i = 0; i < tradeZones.size(); i++) {
                    fw << "tradezone_setup_effect = {\n     TRADE_ZONE = " << tradeZones.at(i) << "_tradezone\n}\n";
                }
            }
            if (zones_from_file == "CLEAR")
            {
                tradeZones.clear();
            }
        }
        tradeZones.clear();
        cout << "\nSetup Effects have been generated successfully.\n";
        fw.close();
    }    
}

int main()
{
    ScriptedTriggers();
    GoodsProducedScriptValues();
    PopulationScriptValues();
    CustomLoc ();
    Localization ();
    SetupEvent ();
}
