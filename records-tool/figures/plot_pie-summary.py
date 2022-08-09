import numpy as np
from matplotlib import cm
import  matplotlib  as mpl
import matplotlib.pyplot as plt


#R1-HR R1-MR R1-LR R2-HR R2-MR R2-LR G-HR G-MR G-LR
#0.9744 0.8686 0.6521 0.7551 0.5591 0.5843 0.8816 1.1314 0.3602

nvalues=6  # 12 #conto due volte i GCMs
values_to_read=np.zeros((nvalues),np.float32)

count=0
domain_m=['EUR','AFR','AUS','NAM','CAM','SAM','EAS','SEA','EAS','WAS','CAS']
scenario_m=['-85','-26']
ic=0
for idomain,domain in enumerate(domain_m):
    for iscenario,scenario in enumerate(scenario_m):
        file_to_read="%s%s%s%s"%('/home/netapp-clima-scratch/lbelleri/records/',domain,scenario,'.log')
        print(file_to_read)
        kount=0
        with open(file_to_read, 'r') as f:
             for line in f:
                 l = line.split()
                 if kount >0 :
                    values_to_read[0]=l[0]#HR giusto
                    values_to_read[1]=l[1]#MR giusto
                    values_to_read[2]=l[2]#LR giusto
                    values_to_read[3]=l[3]#HR giusto
                    values_to_read[4]=l[4]#MR giusto
                    values_to_read[5]=l[5]#LR giusto
#                    values_to_read[6]=l[6]#HR
#                    values_to_read[7]=l[7]#MR
#                    values_to_read[8]=l[8]#LR
#                    values_to_read[9]=l[6]#HR
#                    values_to_read[10]=l[7]#MR giusto
#                    values_to_read[11]=l[8]#LR giusto
                 kount+=1
        f.close()


        values_range=np.arange(-5,25,1)
        values_to_read[np.isnan(values_to_read)]=0

        GCMs=['HadGEM','MPI','NorESM']



        theta = [np.pi/3+1.045, np.pi, np.pi+np.pi/3,np.pi/3-0.005,np.pi/3-1.045,2*np.pi/3-3.14] #[np.pi/2+0.33,np.pi-0.15,np.pi+np.pi/4+0.15,np.pi/4+0.15,0+0.15,2*np.pi-np.pi/4-0.15]# 0.5*np.pi+np.pi/6+0.1,np.pi+0.16,np.pi+np.pi/3+0.18,np.pi/4+0.47,0-0.16,1.5*np.pi+0.33]
        height = 2
        width = np.pi/3 # 0.5*np.pi/5
        fig = plt.figure(figsize=(12,12))
        ax = plt.subplot(111, projection='polar')
        bars=ax.bar(theta,height,width=width,edgecolor='k',bottom=0.0)
        kount=0
        for r, bar in zip(values_to_read, bars):
            if values_to_read[kount] <0 and values_to_read[kount] >-5:
               bar.set_facecolor('#7BC8F6')
            if values_to_read[kount] >0 and values_to_read[kount] <5:
               bar.set_facecolor('yellow')
            if values_to_read[kount] >=5 and values_to_read[kount] <10:
               bar.set_facecolor('darkorange')
            if values_to_read[kount] >=10 and values_to_read[kount] <15:
               bar.set_facecolor('orangered')
            if values_to_read[kount] >=15 and values_to_read[kount] <20:
                bar.set_facecolor('red')
            if values_to_read[kount] >=20 and values_to_read[kount] <25:
               bar.set_facecolor('#8C000F')
#            if values_to_read[kount]>= 2.5:
#               bar.set_facecolor('maroon')
            if values_to_read[kount] == 0: #NaN values
               bar.set_facecolor('lightgrey')
            bar.set_alpha(1)
#            if kount >=3:
#               bar.set_hatch('/')
#               mpl.rcParams['hatch.linewidth']=0.4
            kount+=1   

        ax.set_xticklabels([])
        ax.set_yticklabels([])

#        plt.text(np.pi/2+np.pi/6,1.2,GCMs[0],fontsize=20,rotation=0,weight="bold",ha='center', va='bottom')#RCM HadGEM #(np.pi/2+np.pi/6,max(np.abs(values_range))+0.2,GCMs[0],fontsize=20,rotation=0,weight="bold",ha='center',va='bottom')
#        plt.text(np.pi/2-np.pi/6,1.2,GCMs[0],fontsize=20,rotation=0,weight="bold",ha='center', va='bottom')#GCM HadGEM #plt.text(np.pi/3, max(np.abs(values_range))+0.2,GCMs[0],fontsize=20,rotation=0,weight="bold",ha='center',va='bottom')

#        plt.text(0,1.5,GCMs[1],fontsize=20,rotation=0,weight="bold",ha='center', va='bottom')#RCM MPI #plt.text(0,max(np.abs(values_range))+0.3,GCMs[1],fontsize=20,rotation=0,weight="bold",ha='center',va='bottom')
#        plt.text(np.pi,1.5,GCMs[1],fontsize=20,rotation=0,weight="bold",ha='center', va='bottom')#GCM MPI #plt.text(np.pi,max(np.abs(values_range))+0.3,GCMs[1],fontsize=20,rotation=0,weight="bold",ha='center',va='bottom')

#        plt.text(1.5*np.pi-np.pi/6,1.3,GCMs[2], fontsize=20,rotation=0,weight="bold",ha='center', va='bottom')#RCM NorESM #plt.text(1.5*np.pi-np.pi/6,max(np.abs(values_range))+0.3,GCMs[2],fontsize=20,rotation=0,weight="bold",ha='center', va='bottom')
#        plt.text(1.5*np.pi+np.pi/6,1.3,GCMs[2], fontsize=20,rotation=0,weight="bold",ha='center', va='bottom')#GCM NorESM #plt.text(1.5*np.pi+np.pi/6,max(np.abs(values_range))+0.3,GCMs[2],fontsize=20,rotation=0,weight="bold",ha='center', va='bottom')


#        plt.legend(0,0,domain_m[idomain], fontsize=25,rotation=0,weight="bold",ha='center', va='bottom', bg='white')#TITLE DOMAIN




#        ax.set_rmax(1.5)
#        ax.set_rticks([0.25,0.5,0.75, 1,1.25, 1.5])
        ax.set_rticks([])
#        ax.set_theta_zero_location('N')
#        ax.set_theta_offset(0)
#        ax.set_theta_direction(1)
#        ax.spines['polar'].set_color("black")
        ax.spines['polar'].set_visible(False)
#        ax.spines['polar'].set_alpha(0.5)
        ax.set_axisbelow(True)
        titolo="%s%s"%(domain_m[idomain],scenario_m[iscenario])
        ax.set_title(titolo,y=1.,fontweight="bold",fontsize=40)
#        plt.title(titolo,backgroundcolor='white')
        ax.set_rlabel_position(30)
        ax.xaxis.grid(False)
        ax.yaxis.grid(False)

#        ax.text(0.,0.,titolo, fontsize=75, bbox=dict(facecolor='white',edgecolor='black',boxstyle='round'))
               #  bbox={'facecolor':'white', 'alpha':1, 'pad':10})



        ax1=fig.add_axes([0.25, 0.06, 0.5, 0.03])
        #cbar = mpl.colorbar.ColorbarBase(ax1, cmap=mycmap,orientation='horizontal',
        #               norm=mpl.colors.Normalize(vmin=-1, vmax=1.))
        #cbar.ax.tick_params(labelsize=15)
        #cbar.set_label('[year$^{-1}$]', fontsize=20)
        cmap = mpl.colors.ListedColormap(['#78BCF6','yellow','darkorange','orangered','red','#8C000F'])

        cmap.set_over('#3D1C02')
        cmap.set_under('#069AF3')


        bounds = [-5, 0,5,10,15,20,25]
        norm = mpl.colors.BoundaryNorm(bounds, cmap.N)
        cb2 = mpl.colorbar.ColorbarBase(ax1, cmap=cmap,
                                norm=norm,
                                boundaries=[-10]+bounds+[10],
                                extend='both',
                                extendfrac='auto',
                                ticks=bounds,
                                spacing='uniform',
                                orientation='horizontal')
#        plt.colorbar(im,fraction=0.046, pad=0.04)
        cb2.set_label('[x10$^{-3}$ year$^{-1}$]', fontsize=20)
        nome="%s%s%s"%(domain_m[idomain],scenario_m[iscenario],'.png')
        plt.savefig(nome)
        plt.show()

# levels = np.arange(limmin,limmax+5,5)
#    bounds = levels
#    norm = mpl.colors.BoundaryNorm(bounds, cmap.N, extend='both')
#    cb1 = mpl.colorbar.ColorbarBase(ax1, cmap=cmap,norm=norm,orientation='horizontal',format='%.0f')
#    cb1.ax.tick_params(labelsize=15)
#    cb1.set_label('[%]',fontsize=20)
#   plt.savefig('plot_ts_blind/sbarra_bias_'+VARLIST[ivar]+'_map',bbox_inches='tight',dpi=400)
