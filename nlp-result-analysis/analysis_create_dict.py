
def Aalysis(file_path, languages_dic):

    file = open(file_path)
    for line in file:
        line = line.replace('/', ' ').replace('\n', ' ')
        location = [word for word in line.split()]

        res = file.readline()
        res = [word for word in res.split()]

        accuracy = float(res[-1])
        trained_lan  = location[-2]
        second_lan = location[-1]

        languages_dic[trained_lan][second_lan] = (accuracy)

    file.close()
    print(languages_dic)


languages_dic = {
        'ES': {},
        'PT': {},
        'FR': {},
        'DE': {},
        'NL': {},
        'EN': {},
        'PL': {},
        'FI': {},
        'HU': {},
        'CA': {},
        'IT': {},
        'RU': {},
        'UK': {},
        'BE': {},
        'CS': {},
        'SK': {},
        'RO': {},
        'BG': {},
        'HR': {},
        'SR': {},
        'LT': {},
        'LV': {},
        'ET': {},
        'IS': {},
        'FO': {},
        'NO': {},
        'DA': {},
        'SV': {},
        'GD': {},
        'CY': {},
        'GA': {},
        'FA': {},
        'HI': {},
        'UR': {},
        'HY': {},
        'EL': {},
        'GV': {},
        'GL': {},
        'AF': {},
        'HE': {},
        'AR': {},
        'MT': {}
    }
Aalysis("./print_pre_results/result_prerun.txt", languages_dic)

