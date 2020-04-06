float[][] altitude;
float[][] pente; 
float satMax = 0;
int goutte = 1000;
float sediment = 0.05;
float saturation = 1;
int dureeDeVie = 50000;

void setup() {
  float noiseScale = 0.01;
  size(1000, 1000);
  noiseDetail(16, 0.5);

  altitude = new float[width][height];
  pente = new float[width][height];

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      altitude[x][y] = noise(x*noiseScale, y*noiseScale)*255;
    }
  }
  background(0);
  dessiner();
  deriv();
  genererSortie();
}



void draw() {
  //if (frameCount < 100000) {
  //  if (frameCount % 100 == 0) {    
  //    genererSortie();
  //    println(frameCount);
  //  }
  //  if (frameCount % 1000 == 0) {
  //    background(0);
  //    dessiner();
  //  }
  //}
  println("Image n°" + str(frameCount));
  //dessiner();
  for (int i = 0; i< 10; i++)
  {
    pluie();
    if (i % 1000 == 0) {
      //background(0);
      //dessiner();
      println(i);
    }
  }
  deriv();
  genererSortie();
}




void dessiner() {
  background(0);
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      stroke(altitude[x][y]);
      point(x, y);
    }
  }
}

void pluie() {
  for (int i = 0; i<goutte; i++) {
    int vie = 0;
    float collect = 0;
    int x = int(random(width));
    int y = int(random(height));
    int newx = x;
    int newy = y;

    boolean descendre = true;

    while (descendre && vie < dureeDeVie) { //cette boucle permet de vérifier que l'on a bien fait descendre la goutte au moins une fois.
      vie++;
      //les conditions suivantes permettent de vérifier s'il y a une case moins haute à coté de la case sur laquelle est la goutte de pluie.
      if (x-1 > -1 && y-1 > -1) {
        if (altitude[newx][newy] > altitude[x-1][y-1]) {
          newx = x-1;
          newy = y-1;
        }
      }
      if (y-1 > -1) {
        if (altitude[newx][newy] > altitude[x][y-1]) {
          newx = x;
          newy = y-1;
        }
      }
      if (x+1 < width && y-1 > -1) {
        if (altitude[newx][newy] > altitude[x][y-1]) {
          newx = x+1;
          newy = y-1;
        }
      }
      if (x-1 > -1) {
        if (altitude[newx][newy] > altitude[x-1][y]) {
          newx = x-1;
          newy = y;
        }
      }
      if (x+1 < width) {
        if (altitude[newx][newy] > altitude[x+1][y]) {
          newx = x+1;
          newy = y;
        }
      }
      if (x-1 > -1 && y+1 < height) {
        if (altitude[newx][newy] > altitude[x-1][y+1]) {
          newx = x-1;
          newy = y+1;
        }
      }
      if (y+1 < height) {
        if (altitude[newx][newy] > altitude[x][y+1]) {
          newx = x;
          newy = y+1;
        }
      }
      if (x+1 < width && y+1 < height) {
        if (altitude[newx][newy] > altitude[x+1][y+1]) {
          newx = x+1;
          newy = y+1;
        }
      }
      if (x == newx && y == newy) {
        descendre = false;
        if (altitude[x][y] + collect <= 255) {
          altitude[x][y] += collect;
        } else {
          altitude[x][y] = 255;
        }
        collect = 0;
      } else {
        if (altitude[x][y] - sediment >=0) {
          if (collect < saturation) {
            altitude[x][y] -= sediment;
            collect += sediment;
          }
        }
        x = newx;
        y = newy;

        //stroke(255, 0, 0);
        //strokeWeight(1);
        //point(x, y);
      }
    }
  }
}


void genererSortie() {
  PImage alti = createImage(width, height, GRAY);
  PImage pent = createImage(width, height, GRAY);
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      if (x == 0) {
        alti.pixels[x + y*width] = 0;
        pent.pixels[x + y*width] = 0;
      } else if (x == width - 1) {
        alti.pixels[x + y*width] = 0;
        pent.pixels[x + y*width] = 0;
      } else if (y == 0) {
        alti.pixels[x + y*width] = 0;
        pent.pixels[x + y*width] = 0;
      } else if (y == height -1) {
        alti.pixels[x + y*width] = 0;
        pent.pixels[x + y*width] = 0;
      } else {
        alti.pixels[x + y*width] = color(map(altitude[x][y], 0, 255, 10, 255));
        pent.pixels[x + y*width] = color(map(pente[x][y], 0, satMax, 10, 255));
      }
    }
  }
  alti.save("sortie\\altitude\\" + nom(frameCount, 7) + ".tiff");
  pent.save("sortie\\pente\\" + nom(frameCount, 7) + ".tiff");
}

void deriv() {
  for (int x = 0; x < width; x++) { //<>//
    for (int y = 0; y < height; y++) {
      if (x == 0) {
        pente[x][y] = 0;
      } else if (x == width - 1) {
        pente[x][y] = 0;
      } else if (y == 0) {
        pente[x][y] = 0;
      } else if (y == height - 1) {
        pente[x][y] = 0;
      } else {
        float dx = (altitude[x+1][y] - altitude[x-1][y])/2;
        float dy = (altitude[x][y+1] - altitude[x][y-1])/2;
        float dxdy = norme(dx, dy);
        if(dxdy > satMax){satMax = dxdy;}
        pente[x][y] = dxdy;
      }
    }
  }
}

float norme(float x, float y) {
  return(sqrt(pow(x, 2) + pow(y, 2)));
}

String nom(int nombre, int limite) {
  String nbr = str(nombre);
  String renv = "";
  for (int i = 0; i< limite-nbr.length(); i++) {
    renv += "0";
  }
  return renv + nbr;
}
