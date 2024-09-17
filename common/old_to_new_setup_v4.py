import csv, codecs, json
from enum import IntFlag


class Col(IntFlag):
    # These columns may vary depending on what pops you have added to the game
    id = 0
    name = 15
    culture = 1
    religion = 2
    trade_goods = 3
    civilization = 12
    barbarian = 13
    province_rank = 14
    area = 16
    # Pop values
    citizen = 4
    freemen = 4
    slaves = 9
    tribesmen = 10
    # Pops for the 1815 mod
    lower_strata = 6
    middle_strata = 7
    upper_strata = 11
    proletariat = 8


class ProvinceCollection:
    def __init__(self, filename: str):
        self.uninhabitable = set()
        self._set_uninhabitable(filename)

    def _set_uninhabitable(self, filename: str):
        map_data_file = open(filename)
        map_data = map_data_file.readlines()
        map_data_file.close()
        definitions = {}
        definitions.update([line.split('=') for line in map_data if line.find('{') > 0])

        for k, v in definitions.items():
            kind = v[:v.find('{')].strip()
            vals = v[v.find('{')+1:v.find('}')].strip().split(" ")
            if kind == 'RANGE':
                self.uninhabitable |= set(i for i in range(int(vals[0]), int(vals[1])))
            else:  # LIST
                self.uninhabitable |= set(int(i) for i in vals)

    def is_habitable(self, province_id: int) -> bool:
        return province_id not in self.uninhabitable


class TerrainCollection:
    def __init__(self, filename: str):
        self.terrains = dict()
        self._set_terrains(filename)

    def _set_terrains(self, filename: str):
        terrain_file = open(filename, encoding="utf=8")
        terrain_txt = terrain_file.readlines()
        terrain_file.close()
        kv_pair_list = [map(str.strip, line.split("=")) for line in terrain_txt]
        for (k, v) in kv_pair_list:
            try:
                k = int(k)
            except ValueError:
                pass
            self.terrains[k] = v
        self.terrains[1] = self.terrains['default_land']
        self.terrains[2] = self.terrains['default_water']

    def exists(self, t_id: int):
        return t_id in self.terrains

    def get(self, t_id: int):
        return self.terrains[t_id] if t_id in self.terrains else None


class Thing:
    def __init__(self, row: list, terrains: TerrainCollection, using_1815: bool = True):
        self.t_id = int(row[Col.id])
        # self.area = row[Col.area]
        self.name = row[Col.name]
        self.object = {
            'culture': row[Col.culture],
            'religion': row[Col.religion],
            'trade_goods': row[Col.trade_goods],
            'civilization_value': int(row[Col.civilization]),
            'barbarian_power': int(row[Col.barbarian]),
            'province_rank': row[Col.province_rank],
            'citizen': {'amount': int(row[Col.citizen])},
            'freemen': {'amount': int(row[Col.freemen])},
            'slaves': {'amount': int(row[Col.slaves])},
            'tribesmen': {'amount': int(row[Col.tribesmen])}
        }

        if self.object['province_rank'] == '':
            self.object['province_rank'] = 'settlement'

        self.object['terrain'] = terrains.get(self.t_id)

        if using_1815:
            self.object['lower_strata'] = {'amount': int(row[Col.lower_strata])}
            self.object['middle_strata'] = {'amount': int(row[Col.middle_strata])}
            self.object['upper_strata'] = {'amount': int(row[Col.upper_strata])}
            self.object['proletariat'] = {'amount': int(row[Col.proletariat])}

    def __str__(self) -> str:
        return f'{self.t_id} = {self.object}\n'


class Generator:
    def __init__(self, provinces: ProvinceCollection, terrains: TerrainCollection):
        self.provinces = provinces
        self.terrains = terrains

    def generate(self, in_file: str, out_file: str):
        setup_csv = open(in_file)
        reader = csv.reader(setup_csv, delimiter=",")

        generated_setup = codecs.open(out_file, "w", "utf-8-sig")
        with generated_setup as f:
            for row in reader:
                if row[0][0] != '#':
                    thing = Thing(row, self.terrains)
                    # Ignore sea zones, wastelands, impassable, lakes, rivers etc.
                    if self.provinces.is_habitable(thing.t_id):
                        f.write(str(thing))
        f.close()

def run():
    generator = Generator(
        ProvinceCollection("../map_data/default.map"),
        TerrainCollection("province_terrain/00_province_terrain.txt"),
    )
    generator.generate("OLD_province_setup.csv", "GENERATED_SETUP.txt")


if __name__ == "__main__":
    run()

