//Industrial goods gui/loc generator because im lazy

#include <iostream>
#include <vector>
#include <fstream>
#include <iomanip>
#include <string>

using namespace std;

string upperCase(string strToConvert)
{
    string temp;
    char temp_char;
    for(unsigned int i=0;i<strToConvert.length();i++)
    {
        temp_char = toupper(strToConvert[i]);
        temp.push_back(temp_char);
    }
    return temp;
}

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

void ScriptedGuis ()
{
    string industrial_good;
    vector<string> industrialGood;
    ofstream fw("scripted_guis.txt", ofstream::out);
    ofstream fw2("localization.yml", ofstream::out);
    if (fw.is_open())
    {
        ifstream input_file;
        input_file.open("industrial_goods.in");
        while (industrial_good != "DONE")
        {
            input_file >> industrial_good;
            if (industrial_good != "PRINT")
            {
                industrialGood.push_back(industrial_good);
            }
            else if (industrial_good == "PRINT")
            {
                for (int i = 0; i < industrialGood.size(); i++) {
                    fw << "add_" << industrialGood.at(i) << "_button = {" << endl;
                    fw << "    scope = governorship" << endl;
                    fw << "    saved_scopes = { player }" << endl;
                    fw << "    is_valid = {" << endl;
                    fw << "        #Tech Triggers" << endl;
                    fw << "    }" << endl;
                    fw << "    effect = {" << endl;
                    fw << "        save_scope_as = governorship_name" << endl;
                    fw << "        if = {" << endl;
                    fw << "            limit = {" << endl;
                    fw << "                INDUSTRY_governorship_total_industry_slots > INDUSTRY_governorship_used_industry_slots" << endl;
                    fw << "                has_variable = INDUSTRY_factories_assigned_" << industrialGood.at(i) << endl;
                    fw << "            }" << endl;
                    fw << "            scope:player = { pay_price = add_industry_price }" << endl;
                    fw << "            change_variable = {" << endl;
                    fw << "                name = INDUSTRY_factories_assigned_" << industrialGood.at(i) << endl;
                    fw << "                add = 1" << endl;
                    fw << "            }" << endl;
                    fw << "            custom_tooltip = " << industrialGood.at(i) << "_add_button_tt" << endl;
                    fw << "        }" << endl;
                    fw << "    }" << endl;
                    fw << "}" << endl;
                    fw << "remove_" << industrialGood.at(i) << "_button = {" << endl;
                    fw << "    scope = governorship" << endl;
                    fw << "    effect = {" << endl;
                    fw << "        if = {" << endl;
                    fw << "            limit = {" << endl;
                    fw << "                INDUSTRY_governorship_total_industry_slots > INDUSTRY_governorship_used_industry_slots" << endl;
                    fw << "            }" << endl;
                    fw << "            custom_tooltip = two_newlines_tooltip" << endl;
                    fw << "        }" << endl;
                    fw << "        save_scope_as = governorship_name" << endl;
                    fw << "        show_as_tooltip = { scope:player = { pay_price = remove_industry_price } }" << endl;
                    fw << "        if = {" << endl;
                    fw << "            limit = {" << endl;
                    fw << "                var:INDUSTRY_factories_assigned_" << industrialGood.at(i) << " > 0" << endl;
                    fw << "                scope:player = { can_pay_price = remove_industry_price }" << endl;
                    fw << "            }" << endl;
                    fw << "            hidden_effect = { scope:player = { pay_price = remove_industry_price } }" << endl;
                    fw << "            change_variable = {" << endl;
                    fw << "                name = INDUSTRY_factories_assigned_" << industrialGood.at(i) << "" << endl;
                    fw << "                subtract = 1" << endl;
                    fw << "            }" << endl;
                    fw << "        }" << endl;
                    fw << "        custom_tooltip = " << industrialGood.at(i) << "_remove_button_tt" << endl;
                    fw << "    }" << endl;
                    fw << "}" << endl;
                }
                for (int i = 0; i < industrialGood.size(); i++) {
                    fw2 << "PROVWINDOW_GOV_" << upperCase(industrialGood.at(i)) << "_PRODUCED_TT:0 \"#T " << capitalizeWord(industrialGood.at(i)) << " Industry#!\\n[GetScriptedGui('add_" << industrialGood.at(i) << "_button').BuildTooltip( GuiScope.SetRoot( ProvinceWindow.GetState.GetGovernorship.MakeScope ).AddScope('player', Player.MakeScope ).End )][GetScriptedGui('remove_" << industrialGood.at(i) << "_button').BuildTooltip( GuiScope.SetRoot( ProvinceWindow.GetState.GetGovernorship.MakeScope ).AddScope('player', Player.MakeScope ).End )]\\n\\n#TF [ProvinceWindow.GetState.GetGovernorship.GetNameWithNoTooltip] currently has [GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('INDUSTRY_" << industrialGood.at(i) << "_factories')|0] " << capitalizeWord(industrialGood.at(i)) << " industries. Left click to increase " <<  capitalizeWord(industrialGood.at(i)) << " industries. Right click to decrease " << capitalizeWord(industrialGood.at(i)) << " industries.#!\"" << endl;
                    fw2 << industrialGood.at(i) << "_add_button_tt:0 \"[governorship_name.GetName] gains #Q 1#! " << capitalizeWord(industrialGood.at(i)) << " industry.\"" << endl;
                    fw2 << industrialGood.at(i) << "_remove_button_tt:0 \"Remove #X 1#! " << capitalizeWord(industrialGood.at(i)) << " industry from [governorship_name.GetName].\"" << endl << endl;
                }
            }
        }
        industrialGood.clear();
        cout << "\nIt worked, cool.\n";
        fw.close();
        fw2.close();
    }    
}

void GuiWidgets ()
{
    string industrial_good;
    vector<string> industrialGood;
    ofstream fw("scripted_guis.txt", ofstream::out);
    if (fw.is_open())
    {
        ifstream input_file;
        input_file.open("industrial_goods.in");
        while (industrial_good != "DONE")
        {
            input_file >> industrial_good;
            if (industrial_good != "PRINT")
            {
                industrialGood.push_back(industrial_good);
            }
            else if (industrial_good == "PRINT")
            {
                for (int i = 0; i < industrialGood.size(); i++) {
                    fw << "industrial_goods_widget = {" << endl;
                    fw << "    tooltip = \"PROVWINDOW_GOV_" << upperCase(industrialGood.at(i)) << "_PRODUCED_TT\"" << endl;
                    fw << "    blockoverride \"Icon\"" << endl;
                    fw << "    {" << endl;
                    fw << "        texture = \"gfx/interface/icons/tradegoods/" << industrialGood.at(i) << ".dds\"" << endl;
                    fw << "    }" << endl;
                    fw << "    blockoverride \"IndustriesText\"" << endl;
                    fw << "    {" << endl;
                    fw << "        text = \"PROVWINDOW_GOV_" << upperCase(industrialGood.at(i)) << "_NUM_FACTORIES\"" << endl;
                    fw << "    }" << endl;
                    fw << "    blockoverride \"StockpileText\"" << endl;
                    fw << "    {" << endl;
                    fw << "        text = \"PROVWINDOW_GOV_" << upperCase(industrialGood.at(i)) << "_STOCKPILE\"" << endl;
                    fw << "    }" << endl;
                    fw << "    blockoverride \"On_click\"" << endl;
                    fw << "    {" << endl;
                    fw << "        enabled = \"[GetScriptedGui('add_" << industrialGood.at(i) << "_button').IsValid( GuiScope.SetRoot( ProvinceWindow.GetState.GetGovernorship.MakeScope ).AddScope('player', Player.MakeScope ).End )]\"" << endl;
                    fw << "        onclick = \"[GetScriptedGui('add_" << industrialGood.at(i) << "_button').Execute( GuiScope.SetRoot( ProvinceWindow.GetState.GetGovernorship.MakeScope ).AddScope('player', Player.MakeScope ).End )]\"" << endl;
                    fw << "    }" << endl;
                    fw << "    blockoverride \"On_rightclick\"" << endl;
                    fw << "    {" << endl;
                    fw << "        onrightclick = \"[GetScriptedGui('remove_" << industrialGood.at(i) << "_button').Execute( GuiScope.SetRoot( ProvinceWindow.GetState.GetGovernorship.MakeScope ).AddScope('player', Player.MakeScope ).End )]\"" << endl;
                    fw << "    }" << endl;
                    fw << "}" << endl;
                }
            }
        }
    }
    industrialGood.clear();
    cout << "\nGui is all good.\n";
    fw.close();
}

int main()
{
    ScriptedGuis();
    //GuiWidgets();
}
