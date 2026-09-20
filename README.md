# Headlamp a NUC k3s clusterhez

LAN-on elerheto Kubernetes dashboard a `nuc` clusterhez. A telepites nem hoz letre publikus Ingresst, es nem igenyel uj router-porttovabbitast.

## Biztonsagi modell

- Cim: `http://192.168.1.10:30443` (csak helyi halozatrol hasznald).
- A `headlamp` futasi ServiceAccount nem kap RBAC-jogot.
- A bejelentkezeshez hasznalt `headlamp-operator` csak olvasasi jogot es podtorlest kap.
- Deploymentet, Secretet, RBAC-ot es mas eroforrast nem modosithat.
- A token alapbol 8 ora utan lejar; nincs repoban vagy Kubernetes Secretben tarolt hosszu elettu belepesi token.
- A 30443 portot ne tovabbitsd a routeren, es ne tedd a `pmqxyz.hopto.org` ala.

Pod torlesekor a Deployment/StatefulSet altal felugyelt pod ujra letrejon. Tartós leallitashoz a megfelelo workload replicas erteket kell 0-ra allitani.

## Előfeltetelek

- NUC: `192.168.1.10`, node-nev: `nuc`, architektura: `amd64`
- mukodo k3s es internetkapcsolat az image elso letoltesehez
- a hasznalt kubectl a NUC clusterre mutat

A k3s kubeconfig jogosultsaga miatt a peldakban:

```bash
export KUBECTL='sudo k3s kubectl'
```

## Telepites es frissites

```bash
cd ~/codes/headlamp
git pull --ff-only

KUBECTL='sudo k3s kubectl' ./update.sh --target=nuc --dry-run
KUBECTL='sudo k3s kubectl' ./update.sh --target=nuc
```

A manifest a Headlamp `v0.45.0` image-et rogzitve hasznalja. Frissiteskor elobb a repoban kell modositani ezt a verziót, majd dry-run es normal update kovetkezik.

## Belepes

1. Nyisd meg ugyanazon a LAN-on: <http://192.168.1.10:30443>
2. Generalj rovid elettu tokent:

```bash
KUBECTL='sudo k3s kubectl' ./scripts/token.sh
```

3. Masold a kiirt tokent a Headlamp belepesi mezobe. Ne commitold es ne kuldd el masnak.

## Ellenorzes

```bash
KUBECTL='sudo k3s kubectl' ./scripts/diagnose.sh
curl -I http://192.168.1.10:30443/
```

A jogosultsag-ellenorzes vart vege:

- pod listazasa: `yes`
- pod torlese: `yes`
- Deployment torlese: `no`

## Migracio / ujratelepites

A Headlamp allapotmentes. Masik gepen vagy uj NUC-on eleg ezt a repot klonozni, ellenorizni a `node` nevet/IP-t/NodePortot, majd futtatni a dry-runt es az update-et. Nincs adatbazis vagy PVC, amit masolni kellene. A bongeszoben tarolt regi tokeneket ujratelepites utan torold, es generalj uj tokent.

## Ideiglenes leallitas

```bash
sudo k3s kubectl scale deployment/headlamp -n headlamp-system --replicas=0
```

Visszainditas:

```bash
sudo k3s kubectl scale deployment/headlamp -n headlamp-system --replicas=1
```

## Eltavolitas

```bash
KUBECTL='sudo k3s kubectl' ./scripts/uninstall.sh
```

Ez csak a Headlamp namespace-et es a hozza tartozo RBAC-eroforrasokat torli. A jatekokhoz, Redishez, Ingresshez es mas namespace-ekhez nem nyul.

## Router es tuzfal

A publikus alkalmazasokhoz csak ezek maradjanak a routeren:

- TCP 80 -> `192.168.1.10:31942`
- TCP 443 -> `192.168.1.10:31930`

A korabbi jatekonkenti port forwardok torolhetok. A Headlamp `30443` portjahoz ne keszuljon port forward. Ha a NUC-on UFW aktiv, engedelyezd csak a sajat LAN-t (a halozati tartomanyt ellenorizd futtatas elott):

```bash
sudo ufw allow from 192.168.1.0/24 to any port 30443 proto tcp comment 'Headlamp LAN only'
```

## Forrasok

- [Headlamp in-cluster telepites](https://headlamp.dev/docs/latest/installation/in-cluster/)
- [Headlamp hitelesites es RBAC](https://headlamp.dev/docs/latest/installation/)
- [Headlamp GitHub](https://github.com/kubernetes-sigs/headlamp)
