#!/usr/bin/env bash

if ! command -v helm ; then echo helm not installed ;  exit 0 ; fi
if ! command -v kind ; then echo kind not installed ;  exit 0 ; fi
if ! command -v kubectl ; then echo kubectl not installed ;  exit 0 ; fi
if ! command -v skaffold ; then echo skaffold not installed ;  exit 0 ; fi
if ! command -v terraform ; then echo terraform not installed ;  exit 0 ; fi
if ! command -v vault ; then echo vault not installed ;  exit 0 ; fi
