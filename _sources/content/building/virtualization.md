# Virtualization

Virtualization is the technique of implementing a Nock interpreter in Nock itself.  Not only does this facilitate making practical systems entirely out of Nock (because crashes do not halt the system), it also allows Nock to be extended in powerful ways.  For instance, a virtualized Nock interpreter can implement new opcodes that are not part of the core Nock specification.

* [Virtualized Nock (`+mock`)](https://docs.urbit.org/build-on-urbit/core-academy/ca00#virtualized-nock-mock)
* [Urbit docs, `+mink` evaluator](https://docs.urbit.org/hoon/stdlib/4n#mink)
* [~lacnes (2025) “Metacircular Virtualization & Practical Nock Interpretation”, *Urbit Systems Technical Journal 2*: 1.](https://urbitsystems.tech/article/v02-i01/metacircular-virtualization-and-practical-nock-interpretation)

(In fact, the Urbit and NockApp runtimes both implement the virtualized `+mock` interpreter instead of vanilla Nock 4K, and treat the Nock ISA itself as a special case of the virtualized system.)
