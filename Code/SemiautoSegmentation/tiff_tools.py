
import skimage.external.tifffile as tiff
import os, numpy, re, csv, shutil, sys, subprocess
import scipy.interpolate
import matplotlib.pyplot as plt
import matplotlib.animation as animation

HAVE_PYTHON3 = sys.version_info >= (3, 0)

class RecordingSession(object):

    def __init__(self, images, sampling_rate=None, name="Recording"):
        self.sampling_rate = sampling_rate
        self.name          = name
        self.images        = images
        self._data         = None
        self._removed      = False

    def __str__(self):
        return "RecordingSession of {i} at {r} Hz".format(i=self.filename, r=self.sampling_rate)

    def __len__(self):
        return self.data.shape[0]

    @property
    def filename(self):
        if type(self.images) == dict:
            return "Combined image [left, up: {s}]".format(s=os.path.basename(self.images['left']['up']))
        else:
            return os.path.basename(self.images)

    @property
    def duration(self):
        if self.sampling_rate is not None:
            return self.shape[0] / self.sampling_rate
        else:
            return 0

    @property
    def shape(self):
        return self.data.shape

    @property
    def width(self):
        return self.shape[1]

    @property
    def height(self):
        return self.shape[2]        

    @property
    def data(self):
        if self._data is None:
            if type(self.images) == dict:
                if 'left'in self.images:
                    self._data = self._build_large_tiff()
                else:
                    raise Exception('images should be a dictionary')
            else:
                self._data = tiff.imread(self.images)

        return self._data

    def concatenate(self, session):
        assert self.sampling_rate == session.sampling_rate
        self._data = numpy.vstack((self.data, session._data))

    def _build_large_tiff(self):
        ## images should be a dictionary
        l_up   = tiff.imread(self.images['left']['up'])
        r_up   = tiff.imread(self.images['right']['up'])
        l_down = tiff.imread(self.images['left']['down'])   
        r_down = tiff.imread(self.images['right']['down'])
        up     = numpy.hstack((l_up, r_up))
        down   = numpy.hstack((l_down, r_down))
        return numpy.dstack((up, down))

    def write(self, output_file):
        tiff.imsave(output_file, self.data)

    def resample(self, sampling_rate):
        if self.sampling_rate is not None:
            old_times = numpy.arange(0, self.duration, 1./self.sampling_rate)
            new_times = numpy.arange(0, self.duration, 1./sampling_rate)
            new_data  = numpy.zeros((len(new_times), self.width, self.height))
            for x in range(self.width):
                for y in range(self.height):
                    new_data[:, x, y] = numpy.interp(new_times, old_times, self.data[:, x, y])
            self._data = new_data.astype(numpy.uint16)
            self.sampling_rate = sampling_rate
        else:
            pass

    def show(self, image=None, axes=None):
        if axes is None:
            axes = plt.subplot(1, 1, 1)
        if image is None:
            axes.imshow(self.data.std(axis=0))
        else:
            axes.imshow(self.data[image])
        axes.set_title(self.filename)
        axes.set_xticks([], [])
        axes.set_yticks([], [])
        plt.show()

    def movie(self, interval=10, output=None, axes=None):
        fig = plt.figure()
        plt.title(self.filename)
        ims = []
        for i in range(len(self.data)):
            ims += [(plt.imshow(self.data[i], animated=True), )]

        ani = animation.ArtistAnimation(fig, ims, interval=interval, blit=True)
        if output is not None:
            ani.save(output)
        plt.show()

    def remove_artefacts(self):
        if not self._removed:
            artefacts = numpy.median(self.data, axis=1)
            gmin      = self.data.min()
            self._data = self.data.astype(numpy.float64)
            for count in range(self.shape[0]):
                self._data[count] -= artefacts[count]
            ggmin = self._data.min()
            self._data -= ggmin
            self._data += gmin 
            self._data = self.data.astype(numpy.uint16)
            self._removed = True


class StaticImage(RecordingSession):

    def __init__(self, images, name="Recording"):
        RecordingSession.__init__(self, images, sampling_rate=None, name=name)
    
    def __str__(self):
        return "StaticImage of {i}".format(i=self.filename)

    def show(self, axes=None):
        if axes is None:
            axes = plt.subplot(1, 1, 1)
        axes.imshow(self.data)
        axes.set_title(self.filename)
        axes.set_xticks([], [])
        axes.set_yticks([], [])
        plt.show()


class Experiment(object):

    _internal_mapping = {1 : ['left', 'up'], 
                         4 : ['left', 'down'], 
                         3 : ['right', 'down'], 
                         2 : ['right', 'up']}

    def _read_header(self, file):
        self._recordings = {}
        self._images     = {}

        if HAVE_PYTHON3:
            myfile = open(file, 'r', encoding='ISO-8859-1')
        else:
            myfile = open(file, 'r')

        with myfile as csvfile:
            reader = csv.DictReader((line.replace('\0','') for line in csvfile), delimiter=",", quotechar = '"')
            for row in reader:
                if row['Filename'] != '':
                    if row['FrameRate'] != '':
                        self._recordings[row['Filename'].lower()] = {'sampling_rate' : row['FrameRate'], 
                                                                     'comments' : row['Comments'], 
                                                                     'stim': row['Stimulation Description'],
                                                                     'group' : row['Group'],
                                                                     'for_roi' : row['ForRoi']}
                    else:
                        self._images[row['Filename'].lower()] = {'comments' : row['Comments']}

    def _build_mapping(self, experiments):
        mapping = {'left' : {'up' : None, 'down' : None}, 
                   'right' : {'up' : None, 'down' : None}}

        assert len(experiments) == 4

        for exp in experiments:
            for i in range(1, 5):
                if exp.name.lower().find("square %d" %i) > -1:
                    mapping[self._internal_mapping[i][0]][self._internal_mapping[i][1]] = exp.images
        return mapping

    def _make_plot_path(self):
        self.plot_path = os.path.join(self.path, 'plots')
        if not os.path.exists(self.plot_path):
            os.makedirs(self.plot_path)


    def _is_holo(self, text):
        is_holo = text.lower().find('holo') > -1
        if is_holo:
            stim_key = 'holo'
        else:
            stim_key = 'led'
        return stim_key

    def __init__(self, date, mouse='M1'):
        self.date    = os.path.basename(date.strip('/'))
        self.path    = os.path.abspath(date)
        self.mouse   = mouse
        files        = os.listdir(self.path)

        self.images     = []
        self.recordings = {'holo' : {}, 'led' : {}}
        self._groups    = {}
        self.for_rois   = []
        self.ref_path   = None

        for file in files:
            fname, extension = os.path.splitext(file)
            if extension == '.csv' and fname[0] != '.':
                self._read_header(os.path.join(self.path, file))

        for file in files:
            fname, _ = os.path.splitext(file)
            fname    = fname.lower()
            filename = os.path.join(self.path, file)

            if fname in self._recordings:
                row = self._recordings[fname]
                stim_key = self._is_holo(row['stim'] + ' ' + fname)
                if not row['stim'] in self.recordings[stim_key]:
                    self.recordings[stim_key][row['stim']] = []

                data = RecordingSession(filename, sampling_rate=float(row['sampling_rate'].replace(',', '.')), name=row['comments'])

                if row['group'] != '':
                    if not row['group'] in self._groups:
                        self._groups[row['group']] = {'stim' : row['stim'], 'recordings' : [], 'for_roi' : ''}
                    self._groups[row['group']]['recordings'] += [data]
                    if row['for_roi'] == 'yes':
                        self._groups[row['group']]['for_roi'] = 'yes'
                else:
                    self.recordings[stim_key][row['stim']] += [data]
                    if row['for_roi'] == 'yes':
                        self.for_rois += [data]

            elif fname in self._images:
                row = self._images[fname]
                self.images += [StaticImage(filename, name=row['comments'])]
        
        # ## Need to do the automatic grouping...
        for key in self._groups.keys():
            stim_key = self._groups[key]['stim']
            if len(self._groups[key]['recordings']) == 4:
                mapping = self._build_mapping(self._groups[key]['recordings'])
                rate    = self._groups[key]['recordings'][0].sampling_rate
                print("We can merge 4 corners automatically for stim {s}".format(s=stim_key))
                self.recordings['led'][stim_key] = [RecordingSession(mapping, sampling_rate=rate, name="Merged FOV")]
                if self._groups[key]['for_roi'] == 'yes':
                    self.for_rois += self.recordings['led'][stim_key]

            else:
                print("Only {d} squares for stim {s}".format(d=len(self._groups[key]), s=key))


    def set_hd_image(self, name):
        for i in self.images:
            if i.filename == name:
                self.ref_path = os.path.join(self.path, i.filename)
                print('Reference image is set to known image %s' %self.ref_path)
        if self.ref_path is None:
            if os.path.exists(os.path.join(self.path, name)):
                self.ref_path = os.path.join(self.path, name)      
                print('Reference image is set to custom image %s' %self.ref_path)
            elif os.path.exists(os.path.abspath(name)):
                self.ref_path = os.path.abspath(name)
                print('Reference image is set to custom image %s' %self.ref_path)
            else:
                print('Reference has not been set')


    def launch_pipeline(self, path, remove_artefacts=True, params={'diameter' : 12}, steps=['generate', 'suite_2p', 'gui_export', 'gui'], reference=True):
        
        output_dir = os.path.join(os.path.abspath(path), os.path.join(os.path.join(self.mouse, self.date), '1'))
        nb_frames  = 0
        
        for item in steps:
            if item not in ['generate', 'suite_2p', 'gui_export', 'gui']:
                print('Step %s is not a valid step' %item)
                return

        print("Launchind the pipeline with steps {s}".format(s=steps))

        do_generate = 'generate' in steps
        do_suite2p  = 'suite_2p' in steps
        do_export   = 'gui_export' in steps
        do_gui      = 'gui' in steps

        current_path = os.path.abspath(os.path.curdir)

        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
        else:
            if do_generate:
                shutil.rmtree(output_dir)
                os.makedirs(output_dir)
        
        rate_max = 0
        for recording in self.for_rois:
            if rate_max < recording.sampling_rate:
                rate_max = recording.sampling_rate

        print('All experiments are resampled to a rate of %g Hz' %rate_max)
        if remove_artefacts:
            print('We will also remove any stimulation artefacts')

        if len(self.for_rois) == 0:
            print("No movies for ROI selection")
            return

        x_ref, y_ref = self.for_rois[0].shape[1], self.for_rois[0].shape[2]
        f_ref        = self.for_rois[0].filename

        for stim in self.for_rois[1:]:
            a, b = stim.shape[1], stim.shape[2]
            if (a != x_ref) or (b != y_ref):
                print("All movies does not have the same (x,y) resolution!!")
                print("File {a} has a resolution of {b}".format(a=f_ref, b=(x_ref, y_ref)))
                print("File {a} has a resolution of {b}".format(a=stim.filename, b=(a, b)))
                return 

        for count, stim in enumerate(self.for_rois):

            if do_generate:
                if stim.sampling_rate != rate_max:
                    old_shape = stim.shape
                    old_rate  = stim.sampling_rate
                    stim.resample(rate_max)
                    print('We converted a stim of size {s} at {r} Hz to a size {t}'.format(s=old_shape, r=old_rate, t=stim.shape))
                else:
                    print('We keep a stim of size {s}'.format(s=stim.shape, r=stim.sampling_rate))
                
                if remove_artefacts:
                    stim.remove_artefacts()

                stim.write(os.path.join(output_dir, 'block_%d.tif' %count))
            nb_frames += stim.shape[0]

        if do_suite2p:
            
            to_write ="""
i = 1;
db(i).mouse_name    = '{m}';
db(i).date          = '{d}';
db(i).expts         = [1];
db(i).nplanes       = 1;
db(i).NavgFramesSVD = {s};
db(i).imageRate     = {g};
""".format(d=self.date, m=self.mouse, s=nb_frames//20, g=rate_max)

            for key, value in params.items():
                if type(value) == str:
                    to_write += "db(i).{k} = '{v}';\n".format(k=key, v=value)
                else:
                    to_write += 'db(i).{k} = {v};\n'.format(k=key, v=value)

            file = open(os.path.join(path, 'make_db.m'), 'w')
            file.write(to_write)
            file.close()
            shutil.copy('Suite2P/master_file.m', path)
            shutil.copy('Suite2P/medfilt1.m', path)

        if do_export:
            shutil.copy('MatlabGUI/Suite2pExport.m', path)

        if do_gui:
            shutil.copy('MatlabGUI/SemiAutoROIgui.m', path)
            shutil.copy('MatlabGUI/SemiAutoROIgui.fig', path)
            shutil.copy('MatlabGUI/GetContour.m', path)

        if do_export or do_suite2p or do_gui:
            os.chdir(path)
            print("Launching Suite2P and/or Matlab GUI...")

        try:

            arguments_1 = "'%s'" %(os.path.join(output_dir, 'F_%s_%s_plane1.mat' %(self.mouse, self.date)))
            if reference is True and self.ref_path is not None:
                arguments_2 = "10, '%s', %d, '%s'" %(os.path.join(output_dir, 'block_'), 0, self.ref_path)
            else:
                arguments_2 = "10, '%s', %d" %(os.path.join(output_dir, 'block_'), 0)

            matlab_command = []

            if do_suite2p:
                matlab_command += ['master_file']

            if do_export:
                matlab_command += ['Suite2pExport(%s)' % arguments_1]

            if do_gui:
                matlab_command += ['SemiAutoROIgui(%s)' % arguments_2]

            matlab_command = ' ; '.join(matlab_command)

            
            if len(matlab_command) > 0:

                print(matlab_command)

                subprocess.call(['matlab',
                                      '-nodesktop',
                                      '-nosplash',
                                      '-r', matlab_command])

        except Exception:
            print("Something wrong with MATLAB")
            sys.exit(1)

        os.chdir(current_path)

    def view_images(self, save=True, nb_rows=3):
        nb_images = len(self.images)
        nb_cols = nb_images // nb_rows
        
        if nb_images % nb_rows != 0:
            nb_cols += 1

        fig = plt.figure()
        for count, image in enumerate(self.images):
            axes = plt.subplot(nb_rows, nb_cols, count + 1)
            image.show(axes = axes)

        plt.tight_layout()

        if save is True:
            self._make_plot_path()
            name, _ = os.path.splitext(image.filename)
            plt.savefig(os.path.join(self.plot_path, "images.png"))


    def view_recordings(self, recordings=['holo', 'led'], stim=None, save=True, nb_rows=3):

        for r in recordings:
            if stim is None:
                stims = self.recordings[r]
            else:
                if stim in self.recordings[r]:
                    stims = [stim]
                else:
                    print('Stim {s} is not a valid stim for recordings of type {t}'.format(s=stim, t=r))
                    return

            for s in stims:
                nb_images = len(self.recordings[r][s])

                nb_cols = nb_images // nb_rows
                
                if nb_images % nb_rows != 0:
                    nb_cols += 1

                fig = plt.figure()
                for count, image in enumerate(self.recordings[r][s]):
                    axes = plt.subplot(nb_rows, nb_cols, count + 1)
                    image.show(axes = axes)

                plt.tight_layout()

                if save is True:
                    self._make_plot_path()
                    plt.savefig(os.path.join(self.plot_path, "r_{r}_stim_{s}.png".format(r=r, s=s)))

    def view(self, save=True, nb_rows=3):
        self.view_images(save, nb_rows)
        self.view_recordings(save=save, nb_rows=nb_rows)
