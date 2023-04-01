import numpy as np
import torch
import torch.nn.functional as F

def test():
    filter = torch.randint(12, (5,5)).reshape(1,1,5,5)
    filter=filter.float()
    print(filter)

# timestep 1
    ifmap1 = torch.randint(2, (25,25)).reshape(1,1,25,25)
    ifmap1 = ifmap1.float()
    print(ifmap1)

    out1 = F.conv2d(ifmap1, filter)

    out_spike1 = (out1>64).int()
    residue1 = out1-out_spike1*64 
    print(out1)

# timestep 2
    ifmap2 = torch.randint(2, (25,25)).reshape(1,1,25,25)
    ifmap2 = ifmap2.float()

    out2 = F.conv2d(ifmap2, filter)
    out2 = out2 + residue1
    print(out2)
    out_spike2 = (out2>64).int()
    residue2 = out2-out_spike2*64

    # print(ifmap2)


# write files
# timestep = 1
    with open('./filter.txt', 'w') as ffilter:
        for row in filter[0][0]:
            for ele in row:
                # print(ele)
                ffilter.write(str(int(ele.tolist()))+'\n')
        
        ffilter.write('\n')
        ffilter.write('// Filter matrix \n')
        filter_list=filter[0][0].int().tolist()
        for row in filter_list:
            ffilter.write('// '+str(row)+'\n')
        


    with open('./ifmap1.txt', 'w') as fifmap:
        for row in ifmap1[0][0]:
            for ele in row:
                fifmap.write(str(int(ele.tolist()))+'\n')
        
        fifmap.write('\n')
        fifmap.write('// Ifmap1 matrix \n')
        ifmap_list=ifmap1[0][0].int().tolist()
        for row in ifmap_list:
            fifmap.write('//'+str(row)+'\n')

    
    with open('./ifmap2.txt', 'w') as fifmap:
        for row in ifmap2[0][0]:
            for ele in row:
                fifmap.write(str(int(ele.tolist()))+'\n')
        
        fifmap.write('\n')
        fifmap.write('// Ifmap2 matrix \n')
        ifmap_list=ifmap2[0][0].int().tolist()
        for row in ifmap_list:
            fifmap.write('//'+str(row)+'\n')


    with open('./out_spike1.txt', 'w') as fout:
        for row in out_spike1[0][0]:
            for ele in row:
                fout.write(str(int(ele.tolist()))+'\n')

        fout.write('\n')
        fout.write('// out spike1 matrix \n')
        out_list=out_spike1[0][0].int().tolist()
        for row in out_list:
            fout.write('//'+str(row)+'\n')
    
    with open('./out_spike2.txt', 'w') as fout:
        for row in out_spike2[0][0]:
            for ele in row:
                fout.write(str(int(ele.tolist()))+'\n')

        fout.write('\n')
        fout.write('// out spike2 matrix \n')
        out_list=out_spike2[0][0].int().tolist()
        for row in out_list:
            fout.write('//'+str(row)+'\n')

    with open('./out_residue1.txt', 'w') as fout:
        for row in residue1[0][0]:
            for ele in row:
                fout.write(str(int(ele.tolist()))+'\n')

        fout.write('\n')
        fout.write('// out residue1 matrix \n')
        out_list=residue1[0][0].int().tolist()
        for row in out_list:
            fout.write('//'+str(row)+'\n')

    with open('./out_residue2.txt', 'w') as fout:
        for row in residue2[0][0]:
            for ele in row:
                fout.write(str(int(ele.tolist()))+'\n')

        fout.write('\n')
        fout.write('// out residue2 matrix \n')
        out_list=residue2[0][0].int().tolist()
        for row in out_list:
            fout.write('//'+str(row)+'\n')


if __name__ == '__main__':
    test()

