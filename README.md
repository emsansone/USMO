# USMO (Unlabeled data in Sequential Minimal Optimization) Algorithm

Matlab code for paper [Efficient Training for Positive Unlabeled Learning](https://arxiv.org/abs/1608.06807)

### How to run the code

1. **Install dependencies**

Download [LIBSVM](https://www.csie.ntu.edu.tw/~cjlin/libsvm/#download),
extract the archive into the main directory of USMO and finally compile
the Matlab version of LIBSVM (use the **make.m** file in the uncompressed
folder).

2. **Enjoy**

Use **demo1.m** and **demo2.m** as examples to call USMO routine.

|Visualization of USMO results on MNIST (demo1)|
|---|---|---|
| Linear kernel | Polynomial kernel | Gaussian kernel |
|---|---|---|
| <img src='img/linear.eps'> | <img src='img/polynomial.eps'> | <img src='img/gaussian.eps'> |


