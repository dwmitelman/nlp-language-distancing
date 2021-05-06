
from scipy import stats
import random
import matplotlib.pyplot as plt

def Aalysis(file_path, color, subplot_arg):
    file=open(file_path)

    languages = {
      'english':   {'lan': 0, 'di': 0, 'sub-fa': 'Ge', 'fa': 0},
      'german':    {'lan': 1, 'di': 0, 'sub-fa': 'Ge', 'fa': 0},
      'dutch':     {'lan': 2, 'di': 0, 'sub-fa': 'Ge', 'fa': 0},
      'spanish':   {'lan': 3, 'di': 0, 'sub-fa': 'Ro', 'fa': 0},
      'portugese': {'lan': 3, 'di': 1, 'sub-fa': 'Ro', 'fa': 0},
      'french':    {'lan': 4, 'di': 0, 'sub-fa': 'Ro', 'fa': 0},
      'polish':    {'lan': 5, 'di': 0, 'sub-fa': 'Sl', 'fa': 0},
      'hungarian': {'lan': 6, 'di': 0, 'sub-fa': 'Ug', 'fa': 1},
      'finnish':   {'lan': 7, 'di': 0, 'sub-fa': 'Ba', 'fa': 1}
    }

    languages_distances_by_accuracy = {
      'english':   {},
      'german':    {},
      'dutch':     {},
      'spanish':   {},
      'portugese': {},
      'french':    {},
      'polish':    {},
      'hungarian': {},
      'finnish':   {}
    }

    groups = {0:[], 1:[], 2:[], 3:[], 4:[]}
    couples = []

    for line in file:
        line = line.replace('/', ' ').replace('\n', ' ')
        location = [word for word in line.split()]

        res = file.readline()
        res = [word for word in res.split()]

        accuracy = float(res[-1])
        trained_lan  = location[-2]
        second_lan = location[-1]

        languages_distances_by_accuracy[trained_lan][second_lan] = (accuracy)
        if languages[trained_lan]['lan'] == languages[second_lan]['lan']:
            if languages[trained_lan]['di'] == languages[second_lan]['di']:
                groups[0].append(accuracy)
                couples.append((0, accuracy))
            else:
                groups[1].append(accuracy)
                couples.append((1, accuracy))
        else:
            if languages[trained_lan]['sub-fa'] == languages[second_lan]['sub-fa']:
                groups[2].append(accuracy)
                couples.append((2, accuracy))
            else:
                if languages[trained_lan]['fa'] == languages[second_lan]['fa']:
                    groups[3].append(accuracy)
                    couples.append((3, accuracy))
                else:
                    groups[4].append(accuracy)
                    couples.append((4, accuracy))

    file.close()

    print(languages_distances_by_accuracy)
    print("The average f1:")
    print(" %.4f if train on the same language" % (sum(groups[0]) / len(groups[0])))
    print(" %.4f if train on a different dialect" % (sum(groups[1]) / len(groups[1])))
    print(" %.4f if train on a language from the same sub-family" % (sum(groups[2]) / len(groups[2])))
    print(" %.4f if train on a language from the same family" % (sum(groups[3]) / len(groups[3])))
    print(" %.4f if train on a language from the different family\n" % (sum(groups[4]) / len(groups[4])))

    random.shuffle(couples)
    x=[element[0] for element in couples]
    y=[element[1] for element in couples]

    rho, pval = stats.spearmanr(couples)
    print('Spearman: rho=' + str(rho) +' p_value=' +str(pval))


    rho, pval = stats.pearsonr(x,y)
    print('Pearson: rho=' + str(rho) +' p_value=' +str(pval))
    subplot_arg.scatter(x,y, marker= "*", color=color)
    subplot_arg.axis([-0.5, 4.5, 0.4, 1])

    subplot_arg.set_xlabel('')
    subplot_arg.set_ylabel('cross train f1 score')
    subplot_arg.set_xticks([-1, 0, 1, 2, 3, 4, 5])
    subplot_arg.set_xticklabels(['','same language', 'dialects', 'same subgroup', 'same family', 'different families', ' '])



fig, (ax1, ax2) = plt.subplots(2, 1)
fig.set_size_inches(15, 10)
fig.suptitle('Performance')
ax1.set_title('NO FINE-TUNING')
ax2.set_title('WITH FINE-TUNING')

print('-----NO FINE-TUNING-----')
Aalysis("./print_pre_results/results.txt", 'blue', ax1)

print('\n-----WITH FINE-TUNING-----')
Aalysis("./print_pre_results/results_afterrun.txt", 'pink', ax2)

plt.show()
